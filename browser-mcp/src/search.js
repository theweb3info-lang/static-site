import { getPage, detectCaptcha, humanDelay } from './browser.js';
import { enforceDelay, canUseEngine, recordRequest } from './rate-limiter.js';

const LANG_MAP = {
  google: { zh: 'zh-CN', en: 'en', ja: 'ja', ko: 'ko', de: 'de', fr: 'fr' },
  bing: { zh: 'zh-hans', en: 'en', ja: 'ja', ko: 'ko', de: 'de', fr: 'fr' },
  duckduckgo: { zh: 'cn-zh', en: 'us-en', ja: 'jp-ja', ko: 'kr-ko', de: 'de-de', fr: 'fr-fr' },
};

const ENGINES = {
  google: {
    url: (q, page = 1, language = 'en') => {
      const hl = LANG_MAP.google[language] || language;
      const base = `https://www.google.com/search?q=${encodeURIComponent(q)}&hl=${hl}`;
      return page > 1 ? `${base}&start=${(page - 1) * 10}` : base;
    },
    extract: async (page) => {
      return page.evaluate(() => {
        const results = [];
        document.querySelectorAll('div.g, div[data-sokoban-container]').forEach(el => {
          const a = el.querySelector('a[href]');
          const h3 = el.querySelector('h3');
          const snippet = el.querySelector('[data-sncf], .VwiC3b, [style*="-webkit-line-clamp"]');
          if (a && h3) {
            results.push({
              title: h3.textContent.trim(),
              url: a.href,
              snippet: snippet ? snippet.textContent.trim() : '',
            });
          }
        });
        return results;
      });
    },
  },
  duckduckgo: {
    url: (q, page = 1, language = 'en') => {
      const kl = LANG_MAP.duckduckgo[language] || `us-${language}`;
      return `https://html.duckduckgo.com/html/?q=${encodeURIComponent(q)}&kl=${kl}`;
    },
    paginate: async (browserPage, targetPage) => {
      // DDG HTML uses POST forms for pagination, so we click "Next" repeatedly
      for (let i = 1; i < targetPage; i++) {
        const nextBtn = await browserPage.$('input.btn--alt[value="Next"]');
        if (!nextBtn) throw new Error('No next page button found');
        await Promise.all([
          browserPage.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 15000 }),
          nextBtn.click(),
        ]);
      }
    },
    extract: async (page) => {
      return page.evaluate(() => {
        const results = [];
        document.querySelectorAll('.result').forEach(el => {
          const a = el.querySelector('.result__a');
          const snippet = el.querySelector('.result__snippet');
          if (a) {
            results.push({
              title: a.textContent.trim(),
              url: a.href,
              snippet: snippet ? snippet.textContent.trim() : '',
            });
          }
        });
        return results;
      });
    },
  },
  bing: {
    url: (q, page = 1, language = 'en') => {
      const setlang = LANG_MAP.bing[language] || language;
      const base = `https://www.bing.com/search?q=${encodeURIComponent(q)}&setlang=${setlang}`;
      return page > 1 ? `${base}&first=${(page - 1) * 10 + 1}` : base;
    },
    extract: async (page) => {
      return page.evaluate(() => {
        const results = [];
        document.querySelectorAll('#b_results .b_algo').forEach(el => {
          const a = el.querySelector('h2 a');
          const snippet = el.querySelector('.b_caption p');
          if (a) {
            results.push({
              title: a.textContent.trim(),
              url: a.href,
              snippet: snippet ? snippet.textContent.trim() : '',
            });
          }
        });
        return results;
      });
    },
  },
};

const ENGINE_ORDER = ['google', 'duckduckgo', 'bing'];

export async function search(query, preferredEngine, maxResults = 5, headed = false, pageNum = 1, language = 'en') {
  const order = preferredEngine && ENGINES[preferredEngine]
    ? [preferredEngine, ...ENGINE_ORDER.filter(e => e !== preferredEngine)]
    : [...ENGINE_ORDER];

  // Filter out rate-limited engines, but keep at least one
  const available = order.filter(e => canUseEngine(e));
  const engineList = available.length > 0 ? available : order;

  let lastError = null;

  for (const engineName of engineList) {
    if (!canUseEngine(engineName)) {
      lastError = `${engineName}: rate limited (30/hr)`;
      continue;
    }

    // Enforce delay between requests
    await enforceDelay();

    const browserPage = await getPage(30000, headed);
    try {
      const engine = ENGINES[engineName];
      recordRequest(engineName);

      const resp = await browserPage.goto(engine.url(query, pageNum, language), { waitUntil: 'domcontentloaded' });
      const status = resp?.status() || 0;

      if (status === 403 || status === 429) {
        lastError = `${engineName}: HTTP ${status}`;
        continue;
      }

      // Human-like delay after page load
      await humanDelay();

      // Engine-specific pagination (e.g. DDG uses POST forms)
      if (pageNum > 1 && engine.paginate) {
        await engine.paginate(browserPage, pageNum);
        await humanDelay();
      }

      const html = await browserPage.content();
      if (detectCaptcha(html)) {
        lastError = `${engineName}: captcha detected`;
        continue;
      }

      let results = await engine.extract(browserPage);
      results = results.slice(0, maxResults);

      if (results.length === 0) {
        lastError = `${engineName}: no results extracted`;
        continue;
      }

      return { engine: engineName, page: pageNum, results };
    } catch (err) {
      lastError = `${engineName}: ${err.message}`;
    } finally {
      await browserPage.close().catch(() => {});
    }
  }

  throw new Error(`All search engines failed. Last: ${lastError}`);
}

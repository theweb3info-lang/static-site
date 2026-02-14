#!/usr/bin/env node
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { getPage, closeBrowser, humanDelay, setBrowserEngine, getBrowserEngine } from './browser.js';
import { extractContent } from './extractor.js';
import { search as doSearch } from './search.js';
import { Cache } from './cache.js';
import { enforceDelay, getStats } from './rate-limiter.js';

const searchCache = new Cache(3600000);

const server = new McpServer({
  name: 'browser-mcp',
  version: '1.1.0',
});

// navigate
server.tool('navigate', {
  url: z.string().url(),
  headed: z.boolean().optional().default(false),
}, async ({ url, headed }) => {
  await enforceDelay();
  const page = await getPage(30000, headed);
  try {
    const resp = await page.goto(url, { waitUntil: 'domcontentloaded' });
    await humanDelay();
    const title = await page.title();
    const status = resp?.status() || 0;
    return { content: [{ type: 'text', text: JSON.stringify({ title, status, url }) }] };
  } finally {
    if (!headed) await page.close().catch(() => {});
  }
});

// evaluate
server.tool('evaluate', {
  js: z.string(),
  headed: z.boolean().optional().default(false),
}, async ({ js, headed }) => {
  const page = await getPage(30000, headed);
  try {
    await page.goto('about:blank');
    const result = await page.evaluate(js);
    return { content: [{ type: 'text', text: JSON.stringify(result) }] };
  } finally {
    if (!headed) await page.close().catch(() => {});
  }
});

// getText
server.tool('getText', {
  url: z.string().url(),
  maxChars: z.number().optional(),
  headed: z.boolean().optional().default(false),
}, async ({ url, maxChars, headed }) => {
  await enforceDelay();
  const page = await getPage(30000, headed);
  try {
    await page.goto(url, { waitUntil: 'domcontentloaded' });
    await humanDelay();
    const html = await page.content();
    const { title, content } = extractContent(html, url, maxChars);
    return { content: [{ type: 'text', text: JSON.stringify({ title, content }) }] };
  } finally {
    if (!headed) await page.close().catch(() => {});
  }
});

// search
server.tool('search', {
  query: z.string(),
  engine: z.enum(['google', 'bing', 'duckduckgo']).optional(),
  maxResults: z.number().optional().default(10),
  page: z.number().min(1).optional().default(1).describe('Page number (1-based)'),
  language: z.string().optional().default('en').describe('Language code: en, zh, ja, ko, de, fr'),
  headed: z.boolean().optional().default(false),
}, async ({ query, engine, maxResults, page, language, headed }) => {
  const cacheKey = `${query}|${engine || ''}|${maxResults || 10}|p${page}|${language}`;
  const cached = searchCache.get(cacheKey);
  if (cached) {
    return { content: [{ type: 'text', text: JSON.stringify({ ...cached, cached: true }) }] };
  }
  const result = await doSearch(query, engine, maxResults, headed, page, language);
  searchCache.set(cacheKey, result);
  return { content: [{ type: 'text', text: JSON.stringify(result) }] };
});

// screenshot
server.tool('screenshot', {
  url: z.string().url(),
  headed: z.boolean().optional().default(false),
}, async ({ url, headed }) => {
  await enforceDelay();
  const page = await getPage(30000, headed);
  try {
    await page.goto(url, { waitUntil: 'domcontentloaded' });
    await humanDelay();
    const buf = await page.screenshot({ type: 'png', fullPage: false });
    return { content: [{ type: 'image', data: buf.toString('base64'), mimeType: 'image/png' }] };
  } finally {
    if (!headed) await page.close().catch(() => {});
  }
});

// waitForUser - semi-automatic mode for captcha solving etc.
server.tool('waitForUser', {
  message: z.string().optional().default('Waiting for user action...'),
  timeoutSeconds: z.number().optional().default(120),
}, async ({ message, timeoutSeconds }) => {
  console.error(`\n⏳ [waitForUser] ${message}`);
  console.error(`   Please complete the action in the headed browser window.`);
  console.error(`   Timeout: ${timeoutSeconds}s\n`);

  return new Promise((resolve) => {
    const start = Date.now();
    const check = setInterval(() => {
      const elapsed = (Date.now() - start) / 1000;
      if (elapsed >= timeoutSeconds) {
        clearInterval(check);
        resolve({
          content: [{ type: 'text', text: JSON.stringify({ status: 'timeout', elapsed: Math.round(elapsed) }) }],
        });
      }
    }, 1000);

    // Also listen for stdin input as a signal
    const onData = () => {
      clearInterval(check);
      process.stdin.removeListener('data', onData);
      const elapsed = (Date.now() - start) / 1000;
      resolve({
        content: [{ type: 'text', text: JSON.stringify({ status: 'completed', elapsed: Math.round(elapsed) }) }],
      });
    };
    // Note: in MCP stdio mode, stdin is used for JSON-RPC, so timeout is the primary mechanism
    // The tool basically provides a timed pause for the user to interact with the headed browser
    setTimeout(() => {
      clearInterval(check);
      resolve({
        content: [{ type: 'text', text: JSON.stringify({ status: 'timeout', elapsed: timeoutSeconds }) }],
      });
    }, timeoutSeconds * 1000);
  });
});

// setBrowser - switch browser engine
server.tool('setBrowser', {
  engine: z.enum(['webkit', 'chromium']).describe('Browser engine to use'),
}, async ({ engine }) => {
  setBrowserEngine(engine);
  // Close existing browsers so next call uses new engine
  await closeBrowser();
  return { content: [{ type: 'text', text: JSON.stringify({ engine, status: 'switched' }) }] };
});

// rateLimitStats - check current rate limit usage
server.tool('rateLimitStats', {}, async () => {
  const stats = getStats();
  return { content: [{ type: 'text', text: JSON.stringify(stats) }] };
});

// Start
const transport = new StdioServerTransport();
await server.connect(transport);

process.on('SIGINT', async () => { await closeBrowser(); process.exit(0); });
process.on('SIGTERM', async () => { await closeBrowser(); process.exit(0); });

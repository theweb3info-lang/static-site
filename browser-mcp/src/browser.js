import { webkit, chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const USER_AGENTS = [
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
];

const ACCEPT_LANGUAGES = [
  'en-US,en;q=0.9',
  'en-GB,en;q=0.9',
  'en-US,en;q=0.9,zh-CN;q=0.8',
  'en,zh-CN;q=0.9,zh;q=0.8',
  'en-US,en;q=0.9,ja;q=0.8',
];

const REFERERS = [
  'https://www.google.com/',
  'https://www.bing.com/',
  'https://duckduckgo.com/',
  '',
];

const BLOCK_PATTERNS = [
  /google-analytics\.com/,
  /googletagmanager\.com/,
  /facebook\.net\/.*tracking/,
  /doubleclick\.net/,
  /adservice\.google/,
  /ads\./,
  /tracker\./,
  /analytics\./,
];

const COOKIE_PATH = path.join(process.env.HOME || '/tmp', '.openclaw/workspace/browser-mcp/.cookies.json');

// Browser engine: 'webkit' or 'chromium'
let currentEngine = 'webkit';

export function setBrowserEngine(engine) {
  currentEngine = engine === 'chromium' ? 'chromium' : 'webkit';
}

export function getBrowserEngine() {
  return currentEngine;
}

function getLauncher() {
  return currentEngine === 'chromium' ? chromium : webkit;
}

// Two separate browser instances
let headlessBrowser = null;
let headlessContext = null;
let headedBrowser = null;
let headedContext = null;
let headedLastUsed = 0;
let headedCleanupTimer = null;

const HEADED_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes

function randomUA() {
  return USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)];
}

function randomViewport() {
  const width = 1200 + Math.floor(Math.random() * 721);  // 1200-1920
  const height = 800 + Math.floor(Math.random() * 281);   // 800-1080
  return { width, height };
}

function randomHeaders() {
  return {
    'User-Agent': randomUA(),
    'Accept-Language': ACCEPT_LANGUAGES[Math.floor(Math.random() * ACCEPT_LANGUAGES.length)],
    'Referer': REFERERS[Math.floor(Math.random() * REFERERS.length)],
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
  };
}

function randomContentDelay() {
  return 1000 + Math.random() * 2000; // 1-3 seconds
}

async function setupContext(browser, blockResources = true) {
  let storageState;
  try {
    if (fs.existsSync(COOKIE_PATH)) {
      storageState = JSON.parse(fs.readFileSync(COOKIE_PATH, 'utf-8'));
    }
  } catch {}

  const viewport = randomViewport();
  const ctx = await browser.newContext({
    userAgent: randomUA(),
    viewport,
    ...(storageState ? { storageState } : {}),
  });

  if (blockResources) {
    await ctx.route('**/*', (route) => {
      const url = route.request().url();
      const resourceType = route.request().resourceType();
      if (resourceType === 'image' || resourceType === 'media' || resourceType === 'font') {
        return route.abort();
      }
      if (BLOCK_PATTERNS.some(p => p.test(url))) {
        return route.abort();
      }
      return route.continue();
    });
  }

  return ctx;
}

function scheduleHeadedCleanup() {
  if (headedCleanupTimer) clearTimeout(headedCleanupTimer);
  headedCleanupTimer = setTimeout(async () => {
    const elapsed = Date.now() - headedLastUsed;
    if (elapsed >= HEADED_TIMEOUT_MS && headedBrowser) {
      console.error('[browser-mcp] Headed browser idle for 30min, closing...');
      await closeHeadedBrowser();
    }
  }, HEADED_TIMEOUT_MS + 1000);
}

export async function getBrowser(headed = false) {
  if (headed) {
    headedLastUsed = Date.now();
    scheduleHeadedCleanup();
    if (headedBrowser && headedBrowser.isConnected()) return { browser: headedBrowser, context: headedContext };

    headedBrowser = await getLauncher().launch({ headless: false });
    headedContext = await setupContext(headedBrowser, false); // Don't block images in headed mode
    return { browser: headedBrowser, context: headedContext };
  }

  // Headless
  if (headlessBrowser && headlessBrowser.isConnected()) return { browser: headlessBrowser, context: headlessContext };

  headlessBrowser = await getLauncher().launch({ headless: true });
  headlessContext = await setupContext(headlessBrowser, true);
  return { browser: headlessBrowser, context: headlessContext };
}

export async function getPage(timeoutMs = 30000, headed = false) {
  const { context: ctx } = await getBrowser(headed);
  const page = await ctx.newPage();
  page.setDefaultTimeout(timeoutMs);
  page.setDefaultNavigationTimeout(timeoutMs);
  await page.setExtraHTTPHeaders(randomHeaders());
  return page;
}

/**
 * Sleep for random 1-3 seconds to simulate human reading delay.
 */
export async function humanDelay() {
  await new Promise(resolve => setTimeout(resolve, randomContentDelay()));
}

export async function saveCookies() {
  try {
    const ctx = headlessContext || headedContext;
    if (ctx) {
      const state = await ctx.storageState();
      fs.mkdirSync(path.dirname(COOKIE_PATH), { recursive: true });
      fs.writeFileSync(COOKIE_PATH, JSON.stringify(state));
    }
  } catch {}
}

async function closeHeadedBrowser() {
  if (headedBrowser) {
    await headedBrowser.close().catch(() => {});
    headedBrowser = null;
    headedContext = null;
  }
  if (headedCleanupTimer) {
    clearTimeout(headedCleanupTimer);
    headedCleanupTimer = null;
  }
}

export async function closeBrowser() {
  await saveCookies();
  if (headlessBrowser) {
    await headlessBrowser.close().catch(() => {});
    headlessBrowser = null;
    headlessContext = null;
  }
  await closeHeadedBrowser();
}

export function detectCaptcha(html) {
  const patterns = [
    /captcha/i, /recaptcha/i, /hcaptcha/i,
    /verify you are human/i, /are you a robot/i,
    /unusual traffic/i, /automated queries/i,
    /sorry\/index.*\?continue/i,
  ];
  return patterns.some(p => p.test(html));
}

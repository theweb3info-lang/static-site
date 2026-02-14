// Rate limiter: per-engine hourly limits + random delay between requests

const ENGINE_HOURLY_LIMIT = 30;
const MIN_DELAY_MS = 2000;
const MAX_DELAY_MS = 5000;

// { engineName: [timestamp, ...] }
const requestLog = {};
let lastRequestTime = 0;

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function randomDelay() {
  return MIN_DELAY_MS + Math.random() * (MAX_DELAY_MS - MIN_DELAY_MS);
}

/**
 * Enforce random delay between any two requests.
 */
export async function enforceDelay() {
  const now = Date.now();
  const elapsed = now - lastRequestTime;
  const delay = randomDelay();
  if (lastRequestTime > 0 && elapsed < delay) {
    await sleep(delay - elapsed);
  }
  lastRequestTime = Date.now();
}

/**
 * Check if engine is within hourly limit. Returns true if allowed.
 */
export function canUseEngine(engine) {
  const now = Date.now();
  const oneHourAgo = now - 3600000;
  if (!requestLog[engine]) requestLog[engine] = [];
  // Prune old entries
  requestLog[engine] = requestLog[engine].filter(t => t > oneHourAgo);
  return requestLog[engine].length < ENGINE_HOURLY_LIMIT;
}

/**
 * Record a request for an engine.
 */
export function recordRequest(engine) {
  if (!requestLog[engine]) requestLog[engine] = [];
  requestLog[engine].push(Date.now());
}

/**
 * Get time until engine is available again (ms), or 0 if available now.
 */
export function waitTimeForEngine(engine) {
  if (canUseEngine(engine)) return 0;
  const oldest = requestLog[engine][0];
  return oldest + 3600000 - Date.now();
}

/**
 * Get stats for all engines.
 */
export function getStats() {
  const now = Date.now();
  const oneHourAgo = now - 3600000;
  const stats = {};
  for (const [engine, times] of Object.entries(requestLog)) {
    const recent = times.filter(t => t > oneHourAgo);
    stats[engine] = { used: recent.length, limit: ENGINE_HOURLY_LIMIT, available: ENGINE_HOURLY_LIMIT - recent.length };
  }
  return stats;
}

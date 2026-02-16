/**
 * Rate limiting using Cloudflare KV with date-based keys.
 * Key format: usage:<userId>:<YYYY-MM-DD>
 * Budget key: budget:<YYYY-MM>
 */

function todayKey(userId) {
  const date = new Date().toISOString().slice(0, 10);
  return `usage:${userId}:${date}`;
}

function monthKey() {
  const month = new Date().toISOString().slice(0, 7);
  return `budget:${month}`;
}

export async function checkRateLimit(kv, userId, isPro, limits) {
  const key = todayKey(userId);
  const count = parseInt(await kv.get(key) || '0', 10);
  const limit = isPro ? limits.pro : limits.free;

  return {
    allowed: count < limit,
    count,
    limit,
    remaining: Math.max(0, limit - count),
  };
}

export async function incrementUsage(kv, userId) {
  const key = todayKey(userId);
  const count = parseInt(await kv.get(key) || '0', 10) + 1;
  // Expire after 48h to auto-cleanup
  await kv.put(key, count.toString(), { expirationTtl: 172800 });
  return count;
}

export async function checkMonthlyBudget(kv, budgetCents) {
  const key = monthKey();
  const spent = parseInt(await kv.get(key) || '0', 10);
  return { allowed: spent < budgetCents, spent };
}

export async function addSpend(kv, cents) {
  const key = monthKey();
  const spent = parseInt(await kv.get(key) || '0', 10) + cents;
  // Expire after 35 days
  await kv.put(key, spent.toString(), { expirationTtl: 3024000 });
  return spent;
}

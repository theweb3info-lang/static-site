/**
 * Token format: app_<userId>_<hmacHex>
 * HMAC-SHA256(secret, userId) = hash
 */

async function hmacSign(secret, data) {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const sig = await crypto.subtle.sign('HMAC', key, encoder.encode(data));
  return Array.from(new Uint8Array(sig))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

export async function generateToken(userId, secret) {
  const hash = await hmacSign(secret, userId);
  return `app_${userId}_${hash}`;
}

export async function validateToken(token, secret) {
  if (!token || !token.startsWith('app_')) return null;

  const parts = token.split('_');
  if (parts.length !== 3) return null;

  const userId = parts[1];
  const providedHash = parts[2];

  const expectedHash = await hmacSign(secret, userId);
  if (providedHash !== expectedHash) return null;

  return userId;
}

# AI API Proxy (Cloudflare Worker)

Secure proxy for OpenAI API used by KeigoMaster and AllerScan. Keeps the OpenAI API key server-side and enforces per-user rate limits.

## Architecture

```
Flutter App → Bearer app_userId_hash → CF Worker → OpenAI API
                                          ↕
                                     KV (rate limits)
```

## Setup

### 1. Install Wrangler

```bash
npm install -g wrangler
wrangler login
```

### 2. Create KV Namespace

```bash
wrangler kv:namespace create RATE_LIMIT
```

Copy the output ID into `wrangler.toml` replacing `YOUR_KV_NAMESPACE_ID`.

### 3. Set Secrets

```bash
wrangler secret put OPENAI_API_KEY    # Your OpenAI API key
wrangler secret put TOKEN_SECRET      # Random string for HMAC token signing
```

### 4. Deploy

```bash
npm install
wrangler deploy
```

Your endpoint: `https://ai-api-proxy.<your-subdomain>.workers.dev`

## Generate User Tokens

```javascript
// In Node.js or wrangler dev --remote console:
import { generateToken } from './src/auth.js';

// Free user
const token = await generateToken('user123', 'YOUR_TOKEN_SECRET');
// Pro user (prefix userId with "pro")
const proToken = await generateToken('proUser456', 'YOUR_TOKEN_SECRET');
```

Token format: `app_<userId>_<hmac-sha256-hex>`

## Rate Limits

| Tier | Daily Limit | How to identify |
|------|-------------|-----------------|
| Free | 5 requests  | Default |
| Pro  | 1,000 requests | userId starts with `pro` |

Monthly budget cap: $50 (configurable in wrangler.toml).

## Cost Analysis

**Cloudflare Workers (free tier):**
- 100,000 requests/day — more than enough
- KV: 100,000 reads/day, 1,000 writes/day — fine for small user base

**OpenAI (gpt-4o-mini):**
- Input: $0.15 / 1M tokens
- Output: $0.60 / 1M tokens
- Typical request (~500 input + 200 output tokens): ~$0.0002
- 1,000 requests/day ≈ $0.20/day ≈ $6/month

**Total: effectively free Cloudflare + ~$6-20/month OpenAI** depending on usage.

## Flutter Integration

In your app's constants, switch the base URL:

```dart
// Direct (dev/testing with own API key)
static const String apiBaseUrl = 'https://api.openai.com/v1';

// Via proxy (production)
static const String apiBaseUrl = 'https://ai-api-proxy.YOUR_SUBDOMAIN.workers.dev/v1';
```

Then use `apiBaseUrl` instead of hardcoded OpenAI URL. The proxy accepts the same `/v1/chat/completions` endpoint — just send your app token instead of the OpenAI key.

## Local Development

```bash
wrangler dev
# Worker runs at http://localhost:8787
# Test with: ./test.sh
```

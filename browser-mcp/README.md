# browser-mcp

Lightweight browser MCP Server using Playwright WebKit for web search and content extraction.

## Tools

| Tool | Description |
|------|-------------|
| `navigate(url, headed?)` | Open page, return title + status code |
| `evaluate(js, headed?)` | Execute JS in page, return result |
| `getText(url, maxChars?, headed?)` | Extract readable content as markdown |
| `search(query, engine?, maxResults?, page?, language?, headed?)` | Search via google/bing/duckduckgo with auto-fallback, pagination, and language support (en/zh/ja/ko/de/fr) |
| `screenshot(url, headed?)` | Screenshot page, return base64 PNG |
| `waitForUser(message?, timeoutSeconds?)` | Pause for user action in headed browser (e.g. captcha) |
| `rateLimitStats()` | Check current rate limit usage per engine |

## Features

- **WebKit** — lightweight headless browser
- **Headed mode** — pass `headed: true` to any tool to open a visible browser window
  - Separate browser instance from headless
  - Auto-closes after 30 minutes of inactivity
- **Semi-automatic mode** — `waitForUser` pauses execution for manual intervention (captcha solving, login, etc.)
- **Rate limiting** — random 2-5s delay between requests, 30 requests/hour per search engine, auto engine switching when limited
- **Human behavior simulation** — random viewport (1200-1920 × 800-1080), randomized Accept-Language/Referer headers, 1-3s delay after page load
- **Auto engine switching** — if one search engine blocks (captcha/403/rate limit), tries next
- **Request interception** — blocks ads, trackers, images for speed (headless only)
- **UA rotation** — random User-Agent per page
- **Search caching** — 1hr TTL in-memory cache
- **Cookie persistence** — saves session to local file
- **Captcha detection** — returns clear error instead of garbage HTML

## Setup

```bash
npm install
```

## Register with mcporter

```bash
mcporter add browser-mcp -- node /path/to/browser-mcp/src/index.js
```

## Usage via MCP

The server communicates via JSON-RPC over stdio following the MCP protocol.

### Headed Mode Example

Pass `headed: true` to see the browser in action:
```json
{ "tool": "navigate", "arguments": { "url": "https://example.com", "headed": true } }
```

### Captcha Handling

1. Use `headed: true` to open visible browser
2. When captcha appears, call `waitForUser` with a message
3. Solve captcha manually in the browser window
4. Tool returns after timeout (default 120s)

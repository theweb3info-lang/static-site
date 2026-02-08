import http from 'node:http';

// Route through OpenClaw gateway which has valid Anthropic auth
const GATEWAY_PORT = 18789;
// removed

// We'll use sessions_spawn approach - but that's too slow too.
// Better: use the gateway's /v1/messages proxy if available, or call Anthropic directly.

// Actually let's just ask Andy for an API key. For now, use a lightweight local approach:
// Parse using simple keyword matching as fallback, and call Anthropic when key is available.

const SYSTEM_PROMPT = `You are a scene parser. Given Chinese text, output ONLY a JSON array. No markdown.
Each element: {"type":string,"count":number,"x":0-1,"y":0-1,"scale":number}
Types: sun,moon,stars,clouds,rain,snow,rainbow,mountain,tree,grass,river,lake,flowers,house,building,car,boat,swing,person,child,dog,cat,bird,butterfly,fish,bench,path,fence,bridge,kite,balloon
Layout: sky y:0.05-0.15, flying y:0.15-0.3, mountain y:0.35-0.5, trees/buildings y:0.45-0.6, people/animals y:0.6-0.75, ground y:0.8-0.9
Only valid JSON array.`;

// Keyword-based fallback parser (instant, no API needed)
function keywordParse(text) {
  const t = text;
  const elements = [];
  const numMap = {'一':1,'两':2,'二':2,'三':3,'四':4,'五':5,'六':6,'很多':4,'好多':4,'几个':3,'一些':3,'许多':4};

  function getCount(keyword) {
    const idx = t.indexOf(keyword);
    if (idx > 0) {
      const before = t.substring(Math.max(0, idx - 4), idx);
      for (const [w, n] of Object.entries(numMap)) {
        if (before.includes(w)) return Math.min(n, 6);
      }
    }
    return 1;
  }

  const rules = [
    { kw: ['晴','阳光','太阳','晴朗'], type: 'sun', x: 0.82, y: 0.08 },
    { kw: ['云','多云'], type: 'clouds', x: 0.3, y: 0.1 },
    { kw: ['雨','下雨'], type: 'rain', x: 0.4, y: 0.1 },
    { kw: ['雪','下雪'], type: 'snow', x: 0.3, y: 0.12 },
    { kw: ['月','月亮','晚上','夜'], type: 'moon', x: 0.8, y: 0.08 },
    { kw: ['星星','星空'], type: 'stars', x: 0.3, y: 0.06 },
    { kw: ['彩虹'], type: 'rainbow', x: 0.5, y: 0.25 },
    { kw: ['山','山脉'], type: 'mountain', x: 0.4, y: 0.45 },
    { kw: ['树','森林'], type: 'tree', x: 0.12, y: 0.5 },
    { kw: ['公园'], type: 'tree', x: 0.1, y: 0.5, extra: [
      { type: 'tree', x: 0.88, y: 0.48 },
      { type: 'grass', x: 0, y: 0.83 },
      { type: 'bench', x: 0.75, y: 0.7 },
      { type: 'path', x: 0.5, y: 0.78 },
    ]},
    { kw: ['草','草地'], type: 'grass', x: 0, y: 0.83 },
    { kw: ['河','小河'], type: 'river', x: 0, y: 0.78 },
    { kw: ['湖','湖泊'], type: 'lake', x: 0.5, y: 0.75 },
    { kw: ['花','花朵','花园'], type: 'flowers', x: 0.45, y: 0.78, counted: true },
    { kw: ['房子','房屋','家'], type: 'house', x: 0.75, y: 0.48 },
    { kw: ['城市','大楼','建筑','高楼'], type: 'building', x: 0.3, y: 0.5 },
    { kw: ['汽车','车'], type: 'car', x: 0.6, y: 0.76 },
    { kw: ['船','帆船','小船'], type: 'boat', x: 0.45, y: 0.7 },
    { kw: ['秋千','滑梯','游乐'], type: 'swing', x: 0.4, y: 0.55 },
    { kw: ['小朋友','孩子','小孩','儿童'], type: 'child', x: 0.35, y: 0.65, counted: true },
    { kw: ['人','行人','大人'], type: 'person', x: 0.55, y: 0.62, counted: true, exclude: ['小朋友','孩子','小孩'] },
    { kw: ['狗','小狗','狗狗'], type: 'dog', x: 0.65, y: 0.72 },
    { kw: ['猫','小猫','猫咪'], type: 'cat', x: 0.7, y: 0.7 },
    { kw: ['鸟','小鸟','飞鸟'], type: 'bird', x: 0.4, y: 0.18 },
    { kw: ['蝴蝶'], type: 'butterfly', x: 0.55, y: 0.28 },
    { kw: ['鱼','小鱼'], type: 'fish', x: 0.5, y: 0.8 },
    { kw: ['风筝'], type: 'kite', x: 0.6, y: 0.2 },
    { kw: ['气球'], type: 'balloon', x: 0.3, y: 0.25, counted: true },
    { kw: ['桥'], type: 'bridge', x: 0.5, y: 0.72 },
    { kw: ['栅栏','围栏'], type: 'fence', x: 0.5, y: 0.7 },
  ];

  const added = new Set();
  for (const rule of rules) {
    if (rule.exclude && rule.exclude.some(w => t.includes(w))) continue;
    const matched = rule.kw.find(w => t.includes(w));
    if (!matched) continue;
    if (added.has(rule.type) && !rule.extra) continue;
    added.add(rule.type);

    const count = rule.counted ? Math.max(getCount(matched), 2) : 1;
    elements.push({ type: rule.type, count, x: rule.x, y: rule.y, scale: 1 });
    if (rule.extra) {
      for (const ex of rule.extra) {
        if (!added.has(ex.type)) {
          added.add(ex.type);
          elements.push({ ...ex, count: 1, scale: 1 });
        }
      }
    }
  }
  return elements;
}

// Try Anthropic API if key is provided via env, otherwise use keyword parser
const API_KEY = process.env.ANTHROPIC_API_KEY || '';

async function callAnthropic(text) {
  if (!API_KEY) return keywordParse(text);

  const https = await import('node:https');
  const PROXY = process.env.HTTPS_PROXY || process.env.HTTP_PROXY || '';

  return new Promise((resolve, reject) => {
    const body = JSON.stringify({
      model: 'claude-sonnet-4-20250514', max_tokens: 1024,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: text }],
    });
    const headers = {
      'Content-Type': 'application/json',
      'x-api-key': API_KEY,
      'anthropic-version': '2023-06-01',
      'Content-Length': Buffer.byteLength(body),
    };

    const finish = (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => {
        try {
          if (res.statusCode !== 200) return reject(new Error(`API ${res.statusCode}`));
          const content = JSON.parse(data).content?.[0]?.text || '';
          const m = content.match(/\[[\s\S]*\]/);
          if (!m) return reject(new Error('no JSON'));
          resolve(JSON.parse(m[0]));
        } catch(e) { reject(e); }
      });
    };

    if (PROXY) {
      const proxyUrl = new URL(PROXY);
      const connectReq = http.request({ hostname: proxyUrl.hostname, port: proxyUrl.port, method: 'CONNECT', path: 'api.anthropic.com:443' });
      connectReq.on('connect', (_, socket) => {
        const req = https.request({ hostname: 'api.anthropic.com', path: '/v1/messages', method: 'POST', headers, socket, servername: 'api.anthropic.com' }, finish);
        req.on('error', reject);
        req.setTimeout(15000, () => { req.destroy(); reject(new Error('timeout')); });
        req.write(body); req.end();
      });
      connectReq.on('error', reject);
      connectReq.end();
    } else {
      const req = https.request({ hostname: 'api.anthropic.com', path: '/v1/messages', method: 'POST', headers }, finish);
      req.on('error', reject);
      req.setTimeout(15000, () => { req.destroy(); reject(new Error('timeout')); });
      req.write(body); req.end();
    }
  });
}

async function parseScene(text) {
  if (API_KEY) {
    try { return await callAnthropic(text); }
    catch(e) { console.error('AI fallback to keywords:', e.message); }
  }
  return keywordParse(text);
}

const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }

  if (req.method === 'POST' && req.url === '/parse') {
    let body = '';
    for await (const chunk of req) body += chunk;
    try {
      const { text } = JSON.parse(body);
      if (!text) { res.writeHead(400); res.end('{"error":"no text"}'); return; }
      const mode = API_KEY ? 'AI' : 'keyword';
      console.log(`[${new Date().toLocaleTimeString()}] [${mode}] parse: "${text}"`);
      const t0 = Date.now();
      const elements = await parseScene(text);
      console.log(`[${new Date().toLocaleTimeString()}] done: ${elements.length} elements in ${Date.now()-t0}ms`);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(elements));
    } catch (e) {
      console.error('Error:', e.message);
      res.writeHead(500);
      res.end(JSON.stringify({ error: e.message }));
    }
    return;
  }

  if (req.method === 'GET' && req.url === '/health') { res.writeHead(200); res.end('ok'); return; }
  res.writeHead(404); res.end('not found');
});

server.listen(3942, '127.0.0.1', () => {
  console.log(`🎨 Scene proxy on :3942 [mode: ${API_KEY ? 'AI' : 'keyword'}]`);
});

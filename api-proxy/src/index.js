import { validateToken } from './auth.js';
import { checkRateLimit, incrementUsage, checkMonthlyBudget, addSpend } from './ratelimit.js';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  });
}

function errorResponse(message, status = 400) {
  return jsonResponse({ error: { message, type: 'proxy_error' } }, status);
}

// Rough token estimate: 1 token ≈ 4 chars
function estimateTokens(messages) {
  return messages.reduce((sum, m) => sum + Math.ceil((m.content || '').length / 4), 0);
}

export default {
  async fetch(request, env) {
    // CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    const url = new URL(request.url);

    // Health check
    if (url.pathname === '/health') {
      return jsonResponse({ status: 'ok' });
    }

    // Only allow POST to /v1/chat/completions
    if (url.pathname !== '/v1/chat/completions' || request.method !== 'POST') {
      return errorResponse('Not found', 404);
    }

    // --- Auth ---
    const authHeader = request.headers.get('Authorization') || '';
    const token = authHeader.replace('Bearer ', '');
    const userId = await validateToken(token, env.TOKEN_SECRET);
    if (!userId) {
      return errorResponse('Invalid or missing token', 401);
    }

    // --- Monthly budget check ---
    const budgetCents = parseInt(env.MONTHLY_BUDGET_CENTS || '5000', 10);
    const budget = await checkMonthlyBudget(env.RATE_LIMIT, budgetCents);
    if (!budget.allowed) {
      return errorResponse('Monthly budget exceeded. Service paused.', 503);
    }

    // --- Rate limiting ---
    const limits = {
      free: parseInt(env.DAILY_FREE_LIMIT || '5', 10),
      pro: parseInt(env.DAILY_PRO_LIMIT || '1000', 10),
    };
    // Pro users have userId starting with "pro_" prefix in the token userId field
    const isPro = userId.startsWith('pro');
    const rateCheck = await checkRateLimit(env.RATE_LIMIT, userId, isPro, limits);
    if (!rateCheck.allowed) {
      return errorResponse(
        `Daily limit reached (${rateCheck.limit}). ${isPro ? 'Try again tomorrow.' : 'Upgrade to Pro for more.'}`,
        429
      );
    }

    // --- Parse & validate request ---
    let body;
    try {
      body = await request.json();
    } catch {
      return errorResponse('Invalid JSON body');
    }

    const allowedModel = env.ALLOWED_MODEL || 'gpt-4o-mini';
    if (body.model && body.model !== allowedModel) {
      return errorResponse(`Only ${allowedModel} is allowed`);
    }
    body.model = allowedModel;

    if (!body.messages || !Array.isArray(body.messages) || body.messages.length === 0) {
      return errorResponse('messages array is required');
    }

    const maxTokens = parseInt(env.MAX_INPUT_TOKENS || '4000', 10);
    const inputTokens = estimateTokens(body.messages);
    if (inputTokens > maxTokens) {
      return errorResponse(`Input too large (~${inputTokens} tokens, max ${maxTokens})`);
    }

    // Don't let client stream (simplifies budget tracking)
    body.stream = false;

    // --- Proxy to OpenAI ---
    let openaiResponse;
    try {
      openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${env.OPENAI_API_KEY}`,
        },
        body: JSON.stringify(body),
      });
    } catch (err) {
      return errorResponse('Failed to reach OpenAI API', 502);
    }

    const result = await openaiResponse.json();

    if (!openaiResponse.ok) {
      return jsonResponse(result, openaiResponse.status);
    }

    // --- Track usage ---
    await incrementUsage(env.RATE_LIMIT, userId);

    // Track spend: gpt-4o-mini is ~$0.15/1M input + $0.60/1M output tokens
    // Rough estimate in hundredths of a cent for precision
    const usage = result.usage || {};
    const costCents = Math.ceil(
      ((usage.prompt_tokens || 0) * 0.015 + (usage.completion_tokens || 0) * 0.06) / 100
    );
    if (costCents > 0) {
      await addSpend(env.RATE_LIMIT, costCents);
    }

    // Add rate limit headers
    const remaining = rateCheck.remaining - 1;
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        ...CORS_HEADERS,
        'X-RateLimit-Remaining': remaining.toString(),
        'X-RateLimit-Limit': rateCheck.limit.toString(),
      },
    });
  },
};

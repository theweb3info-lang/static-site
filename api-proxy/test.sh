#!/bin/bash
# Quick test script for ai-api-proxy
# Usage: ./test.sh [worker_url]

WORKER_URL="${1:-http://localhost:8787}"

echo "=== Generate a test token ==="
echo "Run this in Node.js or wrangler dev console:"
echo ""
echo "  import { generateToken } from './src/auth.js';"
echo "  const token = await generateToken('testuser1', 'YOUR_TOKEN_SECRET');"
echo "  console.log(token);"
echo ""

# Replace with a real generated token
TOKEN="${TEST_TOKEN:-app_testuser1_REPLACE_WITH_REAL_HASH}"

echo "=== Testing health endpoint ==="
curl -s "${WORKER_URL}/health" | jq .
echo ""

echo "=== Testing chat completions ==="
curl -s -X POST "${WORKER_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "user", "content": "Say hello in Japanese"}
    ]
  }' | jq .
echo ""

echo "=== Testing invalid token ==="
curl -s -X POST "${WORKER_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid_token" \
  -d '{"messages": [{"role": "user", "content": "test"}]}' | jq .
echo ""

echo "=== Testing wrong model ==="
curl -s -X POST "${WORKER_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{"model": "gpt-4", "messages": [{"role": "user", "content": "test"}]}' | jq .

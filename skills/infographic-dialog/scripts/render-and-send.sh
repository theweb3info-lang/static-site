#!/bin/bash
# render-and-send.sh - Render HTML to PNG and send via email
# Usage: render-and-send.sh <html-path> <topic-name> [email]

set -e

HTML_PATH="$1"
TOPIC_NAME="$2"
EMAIL="${3:-andytest919@gmail.com}"
PNG_PATH="/tmp/${TOPIC_NAME}.png"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$HTML_PATH" ] || [ -z "$TOPIC_NAME" ]; then
  echo "Usage: render-and-send.sh <html-path> <topic-name> [email]"
  exit 1
fi

echo "📸 Rendering ${HTML_PATH} → ${PNG_PATH}..."
node "${SCRIPT_DIR}/html2image.js" "$HTML_PATH" "$PNG_PATH"

SIZE=$(du -h "$PNG_PATH" | cut -f1)
echo "✅ PNG created: ${PNG_PATH} (${SIZE})"

# Check size
BYTES=$(stat -f%z "$PNG_PATH" 2>/dev/null || stat -c%s "$PNG_PATH" 2>/dev/null)
if [ "$BYTES" -gt 10485760 ]; then
  echo "⚠️ File exceeds 10MB (${SIZE}). May need trimming."
  exit 2
fi

echo "📧 Sending to ${EMAIL}..."
cat << EOF | himalaya send
From: theweb3info@gmail.com
To: ${EMAIL}
Subject: 🎨 ${TOPIC_NAME} - Infographic

<#part filename=${PNG_PATH} name=${TOPIC_NAME}.png><#/part>
EOF

echo "✅ Done! Email sent to ${EMAIL} with ${TOPIC_NAME}.png (${SIZE})"

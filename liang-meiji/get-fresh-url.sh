#!/bin/bash
# 生成带缓存破坏参数的链接，用于规避浏览器缓存

ARTICLE="$1"
TIMESTAMP=$(date +%s)

if [ -z "$ARTICLE" ]; then
  echo "用法: $0 <文章编号或名称>"
  echo "示例: $0 11"
  echo "示例: $0 胜海舟"
  exit 1
fi

# 基础URL
BASE_URL="https://theweb3info-lang.github.io/static-site/meiji/zh"

# 如果是数字，补零
if [[ "$ARTICLE" =~ ^[0-9]+$ ]]; then
  NUM=$(printf "%02d" $ARTICLE)
  # 查找对应文件名
  FILE=$(ls /Users/andy_crab/.openclaw/workspace/static-site/meiji/zh/${NUM}-*.html 2>/dev/null | head -1)
  if [ -n "$FILE" ]; then
    FILENAME=$(basename "$FILE")
  else
    echo "❌ 找不到文章编号: $ARTICLE"
    exit 1
  fi
else
  # 按名称搜索
  FILE=$(ls /Users/andy_crab/.openclaw/workspace/static-site/meiji/zh/*${ARTICLE}*.html 2>/dev/null | head -1)
  if [ -n "$FILE" ]; then
    FILENAME=$(basename "$FILE")
  else
    echo "❌ 找不到文章: $ARTICLE"
    exit 1
  fi
fi

# 生成带时间戳的URL
FRESH_URL="${BASE_URL}/${FILENAME}?t=${TIMESTAMP}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 文章: $FILENAME"
echo "🔗 刷新链接:"
echo "$FRESH_URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 提示: 这个链接会跳过浏览器缓存，显示最新内容"

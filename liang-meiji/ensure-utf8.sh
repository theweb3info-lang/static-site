#!/bin/bash
# 确保所有文件都是UTF-8编码，修复常见的日语汉字编码问题

set -e

echo "🔧 确保UTF-8编码..."
echo "━━━━━━━━━━━━━━━━━━━━"

# 1. 检查系统编码环境
echo "📋 当前环境编码:"
echo "  LANG: ${LANG:-未设置}"
echo "  LC_ALL: ${LC_ALL:-未设置}"
echo ""

# 2. 设置UTF-8环境（如果未设置）
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# 3. 检查并修复Markdown文件
echo "🔍 检查Markdown文件..."
cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles

for file in *.md *-tts.txt; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  # 检查是否有替代字符
  if grep -q '�' "$file" 2>/dev/null; then
    echo "⚠️  发现乱码: $file"
    
    # 备份
    cp "$file" "$file.encoding-backup"
    
    # 尝试修复常见问题
    sed -i '' \
      -e 's/本所�/本所/g' \
      -e 's/所�的/所地区的/g' \
      "$file"
    
    echo "   ✓ 已尝试修复（备份: $file.encoding-backup）"
  fi
done

echo ""
echo "🔍 检查HTML文件..."
cd /Users/andy_crab/.openclaw/workspace/static-site/meiji/zh

for file in *.html; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  # 检查charset声明
  if ! grep -q 'charset=UTF-8' "$file" && ! grep -q 'charset="UTF-8"' "$file"; then
    echo "⚠️  缺少UTF-8声明: $file"
  fi
  
  # 检查乱码
  if grep -q '�' "$file" 2>/dev/null; then
    echo "⚠️  发现乱码: $file"
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━"
echo "✅ 编码检查完成"
echo ""
echo "💡 建议："
echo "  1. 生成新文章前运行此脚本"
echo "  2. 如有乱码，检查 liang skill 的输出编码"
echo "  3. 确保 Edge TTS 使用 UTF-8 输入"

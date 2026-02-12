#!/bin/bash
# 儿化音书面化替换脚本
# 将口语儿化音转换为书面语，避免 Edge TTS 读成分开的"尔"音

set -e

if [ $# -lt 1 ]; then
  echo "用法: $0 <input-file> [output-file]"
  echo "示例: $0 article-tts.txt article-tts-fixed.txt"
  exit 1
fi

INPUT="$1"
OUTPUT="${2:-$INPUT}"

if [ ! -f "$INPUT" ]; then
  echo "错误：文件不存在 $INPUT"
  exit 1
fi

# 创建临时文件
TMP=$(mktemp)
cp "$INPUT" "$TMP"

# 儿化音替换规则（高频→低频排序，避免重复替换）
sed -i '' \
  -e 's/自个儿/自己/g' \
  -e 's/一块儿/一起/g' \
  -e 's/一点儿/一点/g' \
  -e 's/有点儿/有点/g' \
  -e 's/这儿/这里/g' \
  -e 's/那儿/那里/g' \
  -e 's/哪儿/哪里/g' \
  -e 's/事儿/事情/g' \
  -e 's/玩儿/玩/g' \
  -e 's/味儿/味道/g' \
  -e 's/头儿/头/g' \
  -e 's/份儿/身份/g' \
  -e 's/劲儿/力气/g' \
  -e 's/活儿/工作/g' \
  -e 's/样儿/样子/g' \
  -e 's/点儿/点/g' \
  -e 's/会儿/会/g' \
  -e 's/明儿/明天/g' \
  -e 's/今儿/今天/g' \
  -e 's/昨儿/昨天/g' \
  -e 's/没词儿/没话说/g' \
  "$TMP"

# 输出到目标文件
mv "$TMP" "$OUTPUT"

echo "✅ 儿化音替换完成: $OUTPUT"

#!/bin/bash
# TTS 文本预处理主脚本
# 按顺序执行所有处理步骤：多音字 → 儿化音 → 人名保护 → 括号清理

set -e

if [ $# -lt 1 ]; then
  echo "用法: $0 <tts-file>"
  echo "示例: $0 articles/01-坂本龙马-tts.txt"
  exit 1
fi

INPUT="$1"
DIR="$(dirname "$INPUT")"
BASE="$(basename "$INPUT" .txt)"

if [ ! -f "$INPUT" ]; then
  echo "❌ 文件不存在: $INPUT"
  exit 1
fi

cd "$(dirname "$0")"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️  TTS 文本预处理流程"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 输入: $INPUT"
echo ""

# 备份原始文件
cp "$INPUT" "$INPUT.original"
echo "💾 原始备份: $INPUT.original"

# Step 0: 清理Markdown格式符号 + 敏感词替换
echo "🔧 Step 0: 清理Markdown格式符号 + 敏感词替换..."
sed -i '' \
  -e 's/\*\*//g' \
  -e 's/\*//g' \
  -e 's/__//g' \
  -e 's/_//g' \
  -e 's/##\+ //g' \
  -e 's/支那/中国/g' \
  "$INPUT"
echo "   ✓ Markdown格式清理完成"
echo "   ✓ 敏感词替换完成（支那→中国）"

# Step 1: 多音字校正（还→环，难标注，高频多音字，年号保护，专有名词保护）
echo "🔧 Step 1: 多音字校正..."
sed -i '' \
  -e 's/大政奉还/大政奉环/g' \
  -e 's/还于朝廷/环于朝廷/g' \
  -e 's/还政/环政/g' \
  -e 's/版籍奉还/版籍奉环/g' \
  -e 's/交还给/交环给/g' \
  -e 's/有多难/有多难(nan2)/g' \
  -e 's/\([^有]\)难度/\1难(nan2)度/g' \
  -e 's/很难/很难(nan2)/g' \
  -e 's/太难/太难(nan2)/g' \
  -e 's/觉得/觉(jue2)得/g' \
  -e 's/睡觉/睡觉(jiao4)/g' \
  -e 's/自觉/自觉(jue2)/g' \
  -e 's/命中/命中(zhong4)/g' \
  -e 's/中举/中(zhong4)举/g' \
  -e 's/中了/中(zhong4)了/g' \
  -e 's/到处/到处(chu4)/g' \
  -e 's/处理/处(chu3)理/g' \
  -e 's/一处/一处(chu4)/g' \
  -e 's/成长/成长(zhang3)/g' \
  -e 's/长度/长(chang2)度/g' \
  -e 's/长官/长(zhang3)官/g' \
  -e 's/上当/上当(dang4)/g' \
  -e 's/当铺/当(dang4)铺/g' \
  -e 's/便宜/便(pian2)宜/g' \
  -e 's/传记/传(zhuan4)记/g' \
  -e 's/着急/着(zhao2)急/g' \
  -e 's/着手/着(zhuo2)手/g' \
  -e 's/落枕/落(lao4)枕/g' \
  -e 's/差别/差(cha1)别/g' \
  -e 's/差不多/差(cha4)不多/g' \
  -e 's/出差/出差(chai1)/g' \
  -e 's/参差/参差(ci1)/g' \
  -e 's/鲜血/鲜血(xue4)/g' \
  -e 's/血淋淋/血(xie3)淋淋/g' \
  -e 's/教书/教(jiao1)书/g' \
  -e 's/行业/行(hang2)业/g' \
  -e 's/银行/银行(hang2)/g' \
  -e 's/庆應\([一二三四五六七八九十元]\+\)年/、庆應\1年、/g' \
  -e 's/安政\([一二三四五六七八九十元]\+\)年/、安政\1年、/g' \
  -e 's/文久\([一二三四五六七八九十元]\+\)年/、文久\1年、/g' \
  -e 's/明治\([一二三四五六七八九十元]\+\)年/、明治\1年、/g' \
  -e 's/天保\([一二三四五六七八九十元]\+\)年/、天保\1年、/g' \
  -e 's/嘉永\([一二三四五六七八九十元]\+\)年/、嘉永\1年、/g' \
  -e 's/大政奉环/、大政奉环、/g' \
  -e 's/萨长同盟/、萨长同盟、/g' \
  -e 's/萨英战争/、萨英战争、/g' \
  -e 's/戊辰战争/、戊辰战争、/g' \
  -e 's/西南战争/、西南战争、/g' \
  -e 's/船中八策/、船中八策、/g' \
  -e 's/鸟羽伏见/、鸟羽伏见、/g' \
  -e 's/王政复古/、王政复古、/g' \
  -e 's/明治维新/、明治维新、/g' \
  -e 's/公武合体/、公武合体、/g' \
  -e 's/尊王攘夷/、尊王攘夷、/g' \
  -e 's/废藩置县/、废藩置县、/g' \
  "$INPUT"
echo "   ✓ 多音字校正完成（包含27个高频多音字）"

# Step 2: 儿化音书面化（TTS cannot pronounce erhua correctly - avoid these words）
echo "🔧 Step 2: 儿化音书面化..."
sed -i '' \
  -e 's/那会儿/那时候/g' \
  -e 's/这会儿/这时候/g' \
  -e 's/哪会儿/什么时候/g' \
  -e 's/那会/那时候/g' \
  -e 's/这会/这时候/g' \
  -e 's/哪会/什么时候/g' \
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
  "$INPUT"
echo "   ✓ 儿化音处理完成（包括：那会→那时候，这会→这时候等）"

# Step 3: 人名保护（Python 脚本）
if [ -f "protect-names.py" ]; then
  echo "🔧 Step 3: 日本人名保护..."
  python3 protect-names.py "$INPUT" "$INPUT"
  echo "   ✓ 人名保护完成"
else
  echo "⚠️  Step 3: protect-names.py 不存在，跳过"
fi

# Step 4: 括号别名清理（Python 脚本）
if [ -f "remove-parentheses.py" ]; then
  echo "🔧 Step 4: 括号别名清理..."
  python3 remove-parentheses.py "$INPUT" "$INPUT"
  echo "   ✓ 括号清理完成"
else
  echo "⚠️  Step 4: remove-parentheses.py 不存在，跳过"
fi

# Step 5: 清理重复顿号
echo "🔧 Step 5: 清理重复顿号..."
sed -i '' \
  -e 's/、、、/、/g' \
  -e 's/、、/、/g' \
  "$INPUT"
echo "   ✓ 清理完成"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 预处理完成！"
echo "📄 输出: $INPUT"
echo "💾 备份: $INPUT.original"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

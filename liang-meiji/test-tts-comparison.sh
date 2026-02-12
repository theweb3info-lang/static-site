#!/bin/bash

# Edge TTS 参数对比测试
# 生成10秒左右的对比音频

cd /Users/andy_crab/.openclaw/workspace/liang-meiji

# 测试文本（约10秒）
TEST_TEXT="话说、明治维新、前后，、坂本龙马、和、西乡隆盛、这两位英雄，一个推动、萨长同盟、，一个领导、戊辰战争、。且说、庆应三年、，日本正经历千年未有之大变局。"

echo "生成 Edge TTS 对比测试音频..."
echo "━━━━━━━━━━━━━━━━━━━━"

# 1. 基础版（当前参数）
echo "1️⃣ 基础版 (rate +10%)"
edge-tts --voice zh-CN-YunjianNeural --rate=+10% -t "$TEST_TEXT" --write-media "test-1-baseline.mp3"

# 2. 语速对比
echo "2️⃣ 语速 +5%"
edge-tts --voice zh-CN-YunjianNeural --rate=+5% -t "$TEST_TEXT" --write-media "test-2-rate-slow.mp3"

echo "3️⃣ 语速 +15%"
edge-tts --voice zh-CN-YunjianNeural --rate=+15% -t "$TEST_TEXT" --write-media "test-3-rate-fast.mp3"

echo "4️⃣ 语速 +20%"
edge-tts --voice zh-CN-YunjianNeural --rate=+20% -t "$TEST_TEXT" --write-media "test-4-rate-veryfast.mp3"

# 3. 音调对比
echo "5️⃣ 音调 +10Hz (更高)"
edge-tts --voice zh-CN-YunjianNeural --rate=+10% --pitch=+10Hz -t "$TEST_TEXT" --write-media "test-5-pitch-high.mp3"

echo "6️⃣ 音调 -10Hz (更低)"
edge-tts --voice zh-CN-YunjianNeural --rate=+10% --pitch=-10Hz -t "$TEST_TEXT" --write-media "test-6-pitch-low.mp3"

# 4. SSML 停顿控制
echo "7️⃣ 加停顿标记"
cat > test-ssml-break.xml << 'EOF'
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="zh-CN">
话说<break time="300ms"/>、明治维新、前后，、坂本龙马、和、西乡隆盛、这两位英雄，<break time="500ms"/>一个推动、萨长同盟、，一个领导、戊辰战争、。且说<break time="300ms"/>、庆应三年、，日本正经历千年未有之大变局。
</speak>
EOF
edge-tts --voice zh-CN-YunjianNeural --rate=+10% -f test-ssml-break.xml --write-media "test-7-ssml-break.mp3"

# 5. SSML 情绪标记
echo "8️⃣ 加情绪标记"
cat > test-ssml-emphasis.xml << 'EOF'
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="zh-CN">
话说、明治维新、前后，<emphasis level="strong">、坂本龙马、和、西乡隆盛、</emphasis>这两位英雄，一个推动、萨长同盟、，一个领导、戊辰战争、。且说、庆应三年、，日本正经历<emphasis level="strong">千年未有之大变局</emphasis>。
</speak>
EOF
edge-tts --voice zh-CN-YunjianNeural --rate=+10% -f test-ssml-emphasis.xml --write-media "test-8-ssml-emphasis.mp3"

echo "━━━━━━━━━━━━━━━━━━━━"
echo "✅ 生成完成！共 8 个测试音频："
echo ""
ls -lh test-*.mp3 2>/dev/null | awk '{print $9, $5}'
echo ""
echo "文件位置: $(pwd)"

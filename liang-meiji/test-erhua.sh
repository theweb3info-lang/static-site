#!/bin/bash
# 测试 Edge TTS 儿化音处理方案

cd "$(dirname "$0")"

VOICE="zh-CN-YunjianNeural"
RATE="+3%"
PITCH="-8Hz"

# 测试文本
echo "生成测试音频..."

# 方案1：原始儿化音（直接读）
echo "您自个儿琢磨去吧，这事儿有点儿意思，一块儿研究研究。" > test-erhua-1-original.txt
edge-tts --voice "$VOICE" --rate="$RATE" --pitch="$PITCH" \
  -f test-erhua-1-original.txt --write-media test-erhua-1-original.mp3

# 方案2：书面化替换
echo "您自己琢磨去吧，这事情有点意思，一起研究研究。" > test-erhua-2-formal.txt
edge-tts --voice "$VOICE" --rate="$RATE" --pitch="$PITCH" \
  -f test-erhua-2-formal.txt --write-media test-erhua-2-formal.mp3

# 方案3：SSML phoneme 标注（测试是否支持）
cat > test-erhua-3-ssml.xml << 'EOF'
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="zh-CN">
  <voice name="zh-CN-YunjianNeural">
    <prosody rate="+3%" pitch="-8Hz">
      您<phoneme alphabet="sapi" ph="zi4 ge3 r">自个儿</phoneme>琢磨去吧，
      这<phoneme alphabet="sapi" ph="shi4 r">事儿</phoneme>
      有<phoneme alphabet="sapi" ph="dian3 r">点儿</phoneme>意思，
      <phoneme alphabet="sapi" ph="yi1 kuai4 r">一块儿</phoneme>研究研究。
    </prosody>
  </voice>
</speak>
EOF

edge-tts --voice "$VOICE" \
  -f test-erhua-3-ssml.xml --write-media test-erhua-3-ssml.mp3 2>&1 | head -20

# 方案4：简化 SSML（去掉复杂标签，仅保留 phoneme）
cat > test-erhua-4-simple-ssml.xml << 'EOF'
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="zh-CN">
  您自个儿琢磨去吧，这事儿有点儿意思，一块儿研究研究。
</speak>
EOF

edge-tts --voice "$VOICE" --rate="$RATE" --pitch="$PITCH" \
  -f test-erhua-4-simple-ssml.xml --write-media test-erhua-4-simple-ssml.mp3

echo ""
echo "✅ 测试音频已生成："
echo "  test-erhua-1-original.mp3   - 原始儿化音"
echo "  test-erhua-2-formal.mp3     - 书面化替换"
echo "  test-erhua-3-ssml.mp3       - SSML phoneme 标注"
echo "  test-erhua-4-simple-ssml.mp3 - 简化 SSML"
echo ""
echo "请听取对比，确定最佳方案。"

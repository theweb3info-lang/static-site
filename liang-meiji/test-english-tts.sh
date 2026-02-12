#!/bin/bash
# 测试英文TTS声音 - 找最适合历史纪录片的音色

cd "$(dirname "$0")"

# 测试文本（坂本龙马开头）
TEXT="In the final years of Japan's feudal era, one man stood at the center of a revolution that would change the nation forever. His name was Sakamoto Ryoma. Neither a powerful lord nor a high-ranking samurai, Ryoma was an outsider, a rogue agent who operated in the shadows. Yet his influence shaped the course of history. This is his story."

echo "🎙️ 生成英文TTS测试样本..."
echo "文本: $TEXT"
echo ""

# 测试声音1: Andrew (温暖自信，纪录片标准音)
echo "1️⃣ Andrew Neural (温暖自信)"
edge-tts --voice en-US-AndrewNeural --rate=+0% --pitch=-5Hz -t "$TEXT" --write-media test-en-andrew.mp3
echo "   ✓ test-en-andrew.mp3"

# 测试声音2: Guy (磁性低沉，成熟男性)
echo "2️⃣ Guy Neural (磁性低沉)"
edge-tts --voice en-US-GuyNeural --rate=+0% --pitch=-8Hz -t "$TEXT" --write-media test-en-guy.mp3
echo "   ✓ test-en-guy.mp3"

# 测试声音3: Eric (年轻有力，适合历史故事)
echo "3️⃣ Eric Neural (年轻有力)"
edge-tts --voice en-US-EricNeural --rate=+0% --pitch=-3Hz -t "$TEXT" --write-media test-en-eric.mp3
echo "   ✓ test-en-eric.mp3"

# 测试声音4: Ryan (多面手，BBC纪录片风格)
echo "4️⃣ Ryan Neural (BBC风格)"
edge-tts --voice en-US-RyanNeural --rate=+0% --pitch=-5Hz -t "$TEXT" --write-media test-en-ryan.mp3
echo "   ✓ test-en-ryan.mp3"

# 测试声音5: 英国口音 - Christopher (英式，历史感强)
echo "5️⃣ Christopher Neural (英式口音)"
edge-tts --voice en-GB-RyanNeural --rate=+0% --pitch=-6Hz -t "$TEXT" --write-media test-en-british.mp3
echo "   ✓ test-en-british.mp3"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 测试音频生成完成！"
echo ""
echo "请试听对比："
echo "  test-en-andrew.mp3  - 温暖自信（纪录片标准）"
echo "  test-en-guy.mp3     - 磁性低沉（老梁感觉）"
echo "  test-en-eric.mp3    - 年轻有力（活泼）"
echo "  test-en-ryan.mp3    - BBC风格（专业）"
echo "  test-en-british.mp3 - 英式口音（历史感）"
echo ""
echo "推荐：Andrew（标准）或 Guy（低沉磁性）"

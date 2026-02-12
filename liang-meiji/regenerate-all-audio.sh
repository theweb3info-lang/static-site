#!/bin/bash

# 用最佳参数重新生成所有中文音频
# 参数：rate +3%, pitch -8Hz

cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles

echo "🎙️ 用最佳参数重新生成音频..."
echo "参数：rate +3%, pitch -8Hz"
echo "━━━━━━━━━━━━━━━━━━━━"

# 中文文章列表
for file in 01-坂本龙马.md 02-西乡隆盛.md 03-德川庆喜.md 04-伊藤博文.md 07-大久保利通.md; do
    base="${file%.md}"
    echo "🔊 生成 ${base}..."
    
    # 检查 TTS 文本是否存在
    if [ ! -f "${base}-tts.txt" ]; then
        echo "⚠️ ${base}-tts.txt 不存在，跳过"
        continue
    fi
    
    # 生成音频（新参数）
    edge-tts --voice zh-CN-YunjianNeural \
             --rate=+3% \
             --pitch=-8Hz \
             -f "${base}-tts.txt" \
             --write-media "${base}.mp3"
             
    if [ $? -eq 0 ]; then
        echo "✅ ${base}.mp3"
    else
        echo "❌ ${base}.mp3 生成失败"
    fi
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━"
echo "✅ 音频生成完成！"
echo ""
ls -lh *.mp3 | grep -E "01-|02-|03-|04-|07-" | awk '{print $9, $5}'

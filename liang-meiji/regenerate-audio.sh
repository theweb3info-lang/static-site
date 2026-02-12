#!/bin/bash

cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles

# Chinese articles
for file in 01-坂本龙马.md 02-西乡隆盛.md 03-德川庆喜.md 04-伊藤博文.md 07-大久保利通.md; do
    base="${file%.md}"
    echo "Processing ${base}..."
    
    # Generate TTS text (simplified - basic cleanup)
    # Remove markdown formatting, preserve basic text
    sed -e 's/^#.*$//' \
        -e 's/\*\*//g' \
        -e 's/__//g' \
        -e 's/\*//g' \
        -e 's/_//g' \
        -e '/^$/d' \
        "$file" > "${base}-tts.txt"
    
    # Generate audio
    edge-tts --voice zh-CN-YunjianNeural \
             --rate=+10% \
             -f "${base}-tts.txt" \
             --write-media "${base}.mp3"
             
    echo "✓ Generated ${base}.mp3"
done

# English articles
for file in 01-sakamoto-ryoma.md 02-saigo-takamori.md 03-tokugawa-yoshinobu.md; do
    base="${file%.md}"
    echo "Processing ${base}..."
    
    # Generate TTS text
    sed -e 's/^#.*$//' \
        -e 's/\*\*//g' \
        -e 's/__//g' \
        -e 's/\*//g' \
        -e 's/_//g' \
        -e '/^$/d' \
        "$file" > "${base}-tts.txt"
    
    # Generate audio
    edge-tts --voice en-US-AndrewNeural \
             --rate=+5% \
             -f "${base}-tts.txt" \
             --write-media "${base}.mp3"
             
    echo "✓ Generated ${base}.mp3"
done

echo "All audio files regenerated!"

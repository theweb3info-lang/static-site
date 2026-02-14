#!/bin/bash
cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles

FILES=(
"17-儿玉源太郎"
"08-吉田松阴"
"32-井上馨"
"07-大久保利通"
"01-坂本龙马"
"02-西乡隆盛"
"67-小松带刀"
"39-岩崎弥太郎"
"15-东乡平八郎"
"24-高桥是清"
"10-木户孝允"
"04-伊藤博文"
"03-德川庆喜"
"34-山内容堂"
"26-岛津齐彬"
"23-西乡从道"
"14-涩泽荣一"
"22-西园寺公望"
)

STATIC=/Users/andy_crab/.openclaw/workspace/static-site/meiji

for name in "${FILES[@]}"; do
  num="${name%%-*}"
  tts="${name}-tts.txt"
  mp3="${name}.mp3"
  echo "Generating: $mp3"
  edge-tts --voice zh-CN-YunjianNeural --rate=+3% --pitch=-8Hz -f "$tts" --write-media "$mp3" &
done

wait
echo "All audio generated."

# Copy to static-site
copied=0
for name in "${FILES[@]}"; do
  num="${name%%-*}"
  mp3="${name}.mp3"
  # Find target dir
  target_dir=$(find "$STATIC" -type d -name "${num}-*" 2>/dev/null | head -1)
  if [ -z "$target_dir" ]; then
    target_dir=$(find "$STATIC" -type d -name "${name}" 2>/dev/null | head -1)
  fi
  if [ -n "$target_dir" ] && [ -f "$mp3" ]; then
    cp "$mp3" "$target_dir/"
    echo "Copied $mp3 -> $target_dir/"
    copied=$((copied+1))
  else
    echo "SKIP $mp3 (no target dir found)"
  fi
done
echo "Copied $copied files to static-site."

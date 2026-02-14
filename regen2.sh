#!/bin/bash
cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles
DEST=/Users/andy_crab/.openclaw/workspace/static-site/meiji/audio/zh

FILES=(
"01-坂本龙马" "02-西乡隆盛" "03-德川庆喜" "04-伊藤博文"
"07-大久保利通" "08-吉田松阴" "10-木户孝允"
"14-涩泽荣一" "15-东乡平八郎" "17-儿玉源太郎"
"22-西园寺公望" "23-西乡从道" "24-高桥是清"
"26-岛津齐彬" "32-井上馨" "34-山内容堂"
"39-岩崎弥太郎" "67-小松带刀"
)

ok=0; copied=0
for name in "${FILES[@]}"; do
  mp3="${name}.mp3"
  for attempt in 1 2 3; do
    edge-tts --voice zh-CN-YunjianNeural --rate=+3% --pitch=-8Hz -f "${name}-tts.txt" --write-media "$mp3" 2>/dev/null && break
    sleep 3
  done
  if [ -f "$mp3" ] && [ -s "$mp3" ]; then
    echo "OK: $mp3"
    ok=$((ok+1))
    if [ -f "$DEST/$mp3" ]; then
      cp "$mp3" "$DEST/$mp3"
      echo "  copied to static-site"
      copied=$((copied+1))
    fi
  else
    echo "FAIL: $mp3"
  fi
  sleep 1
done
echo "=== Generated: $ok/18, Copied to static-site: $copied ==="

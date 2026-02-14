#!/bin/bash
cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles
STATIC=/Users/andy_crab/.openclaw/workspace/static-site/meiji

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

ok=0; fail=0; copied=0
for name in "${FILES[@]}"; do
  tts="${name}-tts.txt"
  mp3="${name}.mp3"
  for attempt in 1 2 3; do
    edge-tts --voice zh-CN-YunjianNeural --rate=+3% --pitch=-8Hz -f "$tts" --write-media "$mp3" 2>/dev/null && break
    sleep 2
  done
  if [ -f "$mp3" ] && [ -s "$mp3" ]; then
    echo "OK: $mp3"
    ok=$((ok+1))
    # Copy to static-site
    target_dir=$(find "$STATIC" -type d -name "${name}" 2>/dev/null | head -1)
    if [ -n "$target_dir" ]; then
      cp "$mp3" "$target_dir/"
      echo "  -> copied to $target_dir/"
      copied=$((copied+1))
    else
      echo "  -> no static dir found"
    fi
  else
    echo "FAIL: $mp3"
    fail=$((fail+1))
  fi
  sleep 1
done
echo "Done: $ok ok, $fail fail, $copied copied"

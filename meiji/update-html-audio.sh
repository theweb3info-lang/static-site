#!/bin/bash

# Update all HTML files to use audio player with auto-advance

cd /Users/andy_crab/.openclaw/workspace/static-site/meiji/zh

for file in *.html; do
  # Add script tag before </body> if not already present
  if ! grep -q "update-audio-player.js" "$file"; then
    sed -i '' 's|</body>|<script src="../update-audio-player.js"></script></body>|' "$file"
  fi
  
  echo "Updated $file"
done

echo "All HTML files updated with audio player script"

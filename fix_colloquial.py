#!/usr/bin/env python3
import glob, os, re

REPLACEMENTS = [
    ("掰扯掰扯", "细细道来"),
    ("您自个儿琢磨去吧", "这其中的道理，值得细细品味"),
    ("您自己琢磨去吧", "这其中的道理，值得细细品味"),
    ("您自个儿琢磨", "这其中的道理，值得细细品味"),
    ("磨叽", "犹豫不决"),
    ("不靠谱", "不可靠"),
]

def replace_in_files(pattern, label):
    files = glob.glob(pattern, recursive=True)
    changed = []
    for f in files:
        text = open(f, 'r', encoding='utf-8').read()
        new = text
        for old, repl in REPLACEMENTS:
            new = new.replace(old, repl)
        if new != text:
            open(f, 'w', encoding='utf-8').write(new)
            changed.append(f)
    print(f"[{label}] {len(changed)}/{len(files)} files changed: {[os.path.basename(f) for f in changed]}")
    return changed

# Step 1: HTML
html_changed = replace_in_files("/Users/andy_crab/.openclaw/workspace/static-site/meiji/**/*.html", "HTML")
replace_in_files("/Users/andy_crab/.openclaw/workspace/static-site/meiji/*.html", "HTML-root")

# Step 2: TTS txt
tts_changed = replace_in_files("/Users/andy_crab/.openclaw/workspace/liang-meiji/articles/*-tts.txt", "TTS")

# Print changed tts files for audio regen
for f in tts_changed:
    print(f"TTS_CHANGED:{f}")

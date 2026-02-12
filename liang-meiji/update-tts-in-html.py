#!/usr/bin/env python3
"""
更新HTML页面中的TTS文本（强制覆盖）
"""

import os
import re
from pathlib import Path

def update_tts_content(html_content, tts_text):
    """更新HTML中的TTS文本内容"""
    
    # 匹配整个TTS区域（从<details到</details>）
    pattern = r'<details class="tts-text">.*?</details>'
    
    # 新的TTS HTML块
    tts_html = f'''<details class="tts-text">
<summary>📝 查看TTS文本（用于音频生成）</summary>
<div class="tts-content">
<pre>{tts_text}</pre>
</div>
</details>'''
    
    # 替换现有的TTS区域
    updated = re.sub(pattern, tts_html, html_content, flags=re.DOTALL)
    
    return updated

def process_html_file(html_path, tts_path):
    """处理单个HTML文件"""
    
    # 读取HTML
    with open(html_path, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    # 读取TTS文本
    if not os.path.exists(tts_path):
        print(f"⚠️  TTS文件不存在: {tts_path}")
        return False
    
    with open(tts_path, 'r', encoding='utf-8') as f:
        tts_text = f.read().strip()
    
    # 检查是否有TTS区域
    if 'class="tts-text"' not in html_content:
        print(f"⏭️  无TTS区域，跳过: {html_path.name}")
        return False
    
    # 更新TTS内容
    updated_html = update_tts_content(html_content, tts_text)
    
    # 写回文件
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(updated_html)
    
    print(f"✅ 已更新TTS文本: {html_path.name}")
    return True

def main():
    """批量更新所有中文HTML文件的TTS文本"""
    
    workspace = Path('/Users/andy_crab/.openclaw/workspace')
    static_zh = workspace / 'static-site/meiji/zh'
    articles = workspace / 'liang-meiji/articles'
    
    if not static_zh.exists():
        print(f"❌ 目录不存在: {static_zh}")
        return
    
    # 获取所有中文HTML文件
    html_files = sorted(static_zh.glob('*.html'))
    
    processed = 0
    skipped = 0
    
    print(f"🔍 找到 {len(html_files)} 个HTML文件")
    print("━━━━━━━━━━━━━━━━━━━━")
    
    for html_path in html_files:
        # 提取文件名前缀
        basename = html_path.stem
        
        # 对应的TTS文件路径
        tts_path = articles / f"{basename}-tts.txt"
        
        if process_html_file(html_path, tts_path):
            processed += 1
        else:
            skipped += 1
    
    print("━━━━━━━━━━━━━━━━━━━━")
    print(f"✅ 完成: {processed} 个文件已更新")
    print(f"⏭️  跳过: {skipped} 个文件")

if __name__ == '__main__':
    main()

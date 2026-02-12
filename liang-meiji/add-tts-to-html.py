#!/usr/bin/env python3
"""
添加TTS文本到HTML页面
在音频播放器下方添加一个折叠的TTS文本显示区域
"""

import os
import re
from pathlib import Path

def add_tts_section(html_content, tts_text):
    """在HTML中的音频区域后添加TTS文本折叠区"""
    
    # TTS文本HTML块
    tts_html = f'''<details class="tts-text">
<summary>📝 查看TTS文本（用于音频生成）</summary>
<div class="tts-content">
<pre>{tts_text}</pre>
</div>
</details>'''
    
    # 在音频区域后插入
    pattern = r'(<div class="audio">.*?</div>)'
    replacement = r'\1\n' + tts_html
    
    updated = re.sub(pattern, replacement, html_content, flags=re.DOTALL)
    
    # 添加TTS区域的CSS样式（如果还没有）
    if '.tts-text' not in updated:
        css_addition = '''
.tts-text { margin: 20px 0; padding: 16px; background: #f5f5f5; border-radius: 8px; border: 1px solid #ddd; }
.tts-text summary { cursor: pointer; font-weight: bold; color: #555; padding: 8px 0; }
.tts-text summary:hover { color: #8B0000; }
.tts-content { margin-top: 12px; padding: 12px; background: #fff; border-radius: 4px; max-height: 400px; overflow-y: auto; }
.tts-content pre { white-space: pre-wrap; word-wrap: break-word; font-family: "SF Mono", Consolas, monospace; font-size: 14px; line-height: 1.6; color: #333; }'''
        
        # 在</style>前插入新CSS
        updated = updated.replace('</style>', css_addition + '\n</style>')
    
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
    
    # 检查是否已经有TTS区域
    if 'class="tts-text"' in html_content:
        print(f"⏭️  已有TTS区域，跳过: {html_path.name}")
        return False
    
    # 添加TTS区域
    updated_html = add_tts_section(html_content, tts_text)
    
    # 写回文件
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(updated_html)
    
    print(f"✅ 已添加TTS文本: {html_path.name}")
    return True

def main():
    """批量处理所有中文HTML文件"""
    
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
        # 提取文件名前缀（如 "05-福泽谕吉"）
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

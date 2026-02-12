#!/usr/bin/env python3
"""
为HTML文件中的资源链接添加时间戳参数，规避浏览器缓存
"""

import os
import time
from pathlib import Path

def add_cache_busting(html_path):
    """给HTML中的音频链接添加时间戳参数"""
    
    with open(html_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 当前时间戳
    timestamp = int(time.time())
    
    # 给音频链接添加时间戳
    # 例如：../audio/zh/11-胜海舟.mp3 → ../audio/zh/11-胜海舟.mp3?v=1234567890
    import re
    
    # 匹配音频链接
    pattern = r'(href="\.\.\/audio\/zh\/[^"]+\.mp3)"'
    replacement = rf'\1?v={timestamp}"'
    
    updated = re.sub(pattern, replacement, content)
    
    # 检查是否有变化
    if updated == content:
        return False
    
    # 写回文件
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(updated)
    
    return True

def main():
    """批量处理所有HTML文件"""
    
    static_zh = Path('/Users/andy_crab/.openclaw/workspace/static-site/meiji/zh')
    
    if not static_zh.exists():
        print(f"❌ 目录不存在: {static_zh}")
        return
    
    html_files = sorted(static_zh.glob('*.html'))
    
    updated = 0
    skipped = 0
    
    timestamp = int(time.time())
    
    print(f"🔧 添加缓存破坏参数: ?v={timestamp}")
    print("━━━━━━━━━━━━━━━━━━━━")
    
    for html_path in html_files:
        if add_cache_busting(html_path):
            print(f"✅ 已更新: {html_path.name}")
            updated += 1
        else:
            print(f"⏭️  跳过: {html_path.name}")
            skipped += 1
    
    print("━━━━━━━━━━━━━━━━━━━━")
    print(f"✅ 完成: {updated} 个文件已更新")
    print(f"⏭️  跳过: {skipped} 个文件")
    print(f"📝 缓存参数: v={timestamp}")

if __name__ == '__main__':
    main()

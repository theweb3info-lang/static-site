#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
删除TTS文本中的括号及括号内容
避免语音啰嗦，保持简洁
"""

import re
import glob
import os

def remove_parentheses(text):
    """删除所有括号及括号内容（中英文括号）"""
    # 中文括号
    text = re.sub(r'（[^）]*）', '', text)
    # 英文括号
    text = re.sub(r'\([^)]*\)', '', text)
    # 方括号
    text = re.sub(r'[\[\]][^\]]*[\]\[]', '', text)
    
    # 清理可能产生的多余空格
    text = re.sub(r'\s+', ' ', text)
    text = re.sub(r' ([，。！？；：、])', r'\1', text)  # 标点前不要空格
    
    return text

def process_file(filepath):
    """处理单个TTS文本文件"""
    print(f"Processing {os.path.basename(filepath)}...")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()
    
    # 备份
    backup_path = filepath + '.paren-bak'
    if not os.path.exists(backup_path):
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(text)
    
    # 删除括号
    text = remove_parentheses(text)
    
    # 写回文件
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(text)
    
    print(f"✓ {os.path.basename(filepath)}")

def main():
    os.chdir('/Users/andy_crab/.openclaw/workspace/liang-meiji/articles')
    
    tts_files = glob.glob('*-tts.txt')
    # 排除备份文件
    tts_files = [f for f in tts_files if not any(f.endswith(ext) for ext in ['.bak', '.name-bak', '.paren-bak'])]
    
    if not tts_files:
        print("No TTS files found")
        return
    
    for filepath in tts_files:
        process_file(filepath)
    
    print(f"\n✅ Processed {len(tts_files)} files")
    print("Backups saved as *.paren-bak")
    print("\n示例：")
    print("  原文：木户孝允（桂小五郎）")
    print("  TTS：木户孝允")

if __name__ == '__main__':
    main()

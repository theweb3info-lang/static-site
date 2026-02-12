#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
日本人名保护脚本 - 确保TTS完整读出人名
"""

import re
import glob
import os

# 明治维新人物名单（全名）
NAMES = [
    "坂本龙马", "西乡隆盛", "大久保利通", "德川庆喜", "伊藤博文",
    "木户孝允", "桂小五郎", "岩仓具视", "胜海舟", "高杉晋作",
    "岛津齐彬", "岛津久光", "中冈慎太郎", "后藤象二郎", "山内容堂",
    "福泽谕吉", "井伊直弼", "近藤勇", "土方岁三", "大村益次郎",
    "吉田松阴", "榎本武扬", "板垣退助", "大隈重信", "井上馨",
    "岩崎弥太郎", "东乡平八郎", "乃木希典", "山县有朋", "西乡从道",
    "小松带刀", "久坂玄瑞", "武市半平太", "江藤新平", "陆奥宗光",
    "黑田清隆", "大山岩", "松平容保", "松平春嶽", "伊达宗城",
    "高桥是清", "涩泽荣一", "夏目漱石", "明治天皇", "孝明天皇",
    "德川家茂", "德川家康", "德川齐昭", "毛利敬亲", "新岛八重",
    "天璋院", "和宫", "津田梅子", "与谢野晶子", "大鸟圭介",
    "河井继之助", "中浜万次郎", "佐久间象山", "中江兆民", "小栗忠顺",
    "马修·佩里", "高岛秋帆", "横井小楠", "小村寿太郎", "森有礼",
    "中村正直", "新渡户稻造", "井上勝", "遠藤謹助", "山尾庸三",
    "锅岛直正", "岛津齐兴", "三条实美"
]

def protect_name(text, name):
    """给人名前后加顿号保护，避免重复"""
    # 如果已经有顿号保护，跳过
    if f"、{name}、" in text:
        return text
    
    # 模式：不在顿号内的人名
    # 使用负向前瞻和后顾，确保前后没有顿号
    pattern = f"(?<!、){re.escape(name)}(?!、)"
    replacement = f"、{name}、"
    
    return re.sub(pattern, replacement, text)

def process_file(filepath):
    """处理单个TTS文本文件"""
    print(f"Processing {os.path.basename(filepath)}...")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()
    
    # 备份
    backup_path = filepath + '.name-bak'
    if not os.path.exists(backup_path):
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(text)
    
    # 按长度排序（先处理长名字，避免部分匹配）
    sorted_names = sorted(NAMES, key=len, reverse=True)
    
    for name in sorted_names:
        text = protect_name(text, name)
    
    # 清理多余的顿号
    text = re.sub(r'、{3,}', '、', text)  # 三个以上顿号 -> 一个
    text = re.sub(r'、{2}', '、', text)   # 两个顿号 -> 一个
    
    # 写回文件
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(text)
    
    print(f"✓ {os.path.basename(filepath)}")

def main():
    os.chdir('/Users/andy_crab/.openclaw/workspace/liang-meiji/articles')
    
    tts_files = glob.glob('*-tts.txt')
    # 排除备份文件
    tts_files = [f for f in tts_files if not f.endswith('.bak') and not f.endswith('.name-bak')]
    
    if not tts_files:
        print("No TTS files found")
        return
    
    for filepath in tts_files:
        process_file(filepath)
    
    print(f"\n✅ Processed {len(tts_files)} files")
    print("Backups saved as *.name-bak")

if __name__ == '__main__':
    main()

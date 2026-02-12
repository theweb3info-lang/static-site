#!/usr/bin/env python3
"""
检查和修复中文编码问题
确保繁体字、日语汉字、简体字都能正常显示
"""

import os
import re
from pathlib import Path

def check_encoding(file_path):
    """检查文件编码是否有问题"""
    
    issues = []
    
    try:
        # 尝试UTF-8读取
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 检查替代字符（�，U+FFFD）
        if '�' in content:
            # 找出所有包含�的行
            lines = content.split('\n')
            for i, line in enumerate(lines, 1):
                if '�' in line:
                    # 截取上下文（前后20个字符）
                    pos = line.find('�')
                    start = max(0, pos - 20)
                    end = min(len(line), pos + 20)
                    context = line[start:end]
                    issues.append({
                        'type': 'replacement_char',
                        'line': i,
                        'context': context,
                        'position': pos
                    })
        
        # 检查常见的编码混乱模式
        # 例如：中文字符后跟乱码
        problematic_patterns = [
            r'[\u4e00-\u9fff][\x00-\x1f]',  # 中文后跟控制字符
            r'[\u4e00-\u9fff]\?{2,}',        # 中文后跟多个问号
        ]
        
        for pattern in problematic_patterns:
            matches = re.finditer(pattern, content)
            for match in matches:
                line_num = content[:match.start()].count('\n') + 1
                issues.append({
                    'type': 'pattern_mismatch',
                    'line': line_num,
                    'pattern': pattern,
                    'text': match.group()
                })
        
    except UnicodeDecodeError as e:
        issues.append({
            'type': 'decode_error',
            'error': str(e)
        })
    
    return issues

def fix_common_issues(content):
    """修复常见的编码问题"""
    
    fixed = content
    changes = []
    
    # 已知的常见乱码修复
    replacements = {
        # 日本地名相关
        '本所�': '本所',  # 如果单独出现，可能是"本所"就够了
        '所�的': '所地区的',  # 本所地区
        
        # 其他可能的日语汉字问题（待补充）
    }
    
    for old, new in replacements.items():
        if old in fixed:
            fixed = fixed.replace(old, new)
            changes.append(f"'{old}' → '{new}'")
    
    return fixed, changes

def validate_html_encoding(html_path):
    """验证HTML文件的charset声明"""
    
    with open(html_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 检查是否有正确的charset声明
    has_utf8 = 'charset=UTF-8' in content or 'charset="UTF-8"' in content
    
    return has_utf8

def main():
    """批量检查所有文章文件"""
    
    workspace = Path('/Users/andy_crab/.openclaw/workspace/liang-meiji')
    
    print("🔍 检查中文编码问题...")
    print("━━━━━━━━━━━━━━━━━━━━")
    
    total_issues = 0
    files_with_issues = []
    
    # 检查Markdown文件
    md_files = sorted((workspace / 'articles').glob('*.md'))
    for md_file in md_files:
        issues = check_encoding(md_file)
        if issues:
            print(f"⚠️  {md_file.name}:")
            for issue in issues:
                if issue['type'] == 'replacement_char':
                    print(f"   行 {issue['line']}: 发现替代字符 � ")
                    print(f"   上下文: ...{issue['context']}...")
                    total_issues += 1
            files_with_issues.append(md_file)
    
    # 检查HTML文件
    html_files = sorted(Path('/Users/andy_crab/.openclaw/workspace/static-site/meiji/zh').glob('*.html'))
    for html_file in html_files:
        # 检查charset声明
        if not validate_html_encoding(html_file):
            print(f"⚠️  {html_file.name}: 缺少 UTF-8 charset 声明")
            total_issues += 1
        
        # 检查内容
        issues = check_encoding(html_file)
        if issues:
            for issue in issues:
                if issue['type'] == 'replacement_char':
                    print(f"⚠️  {html_file.name} 行 {issue['line']}: 发现乱码")
                    total_issues += 1
    
    print("━━━━━━━━━━━━━━━━━━━━")
    
    if total_issues == 0:
        print("✅ 所有文件编码正常")
    else:
        print(f"⚠️  发现 {total_issues} 个编码问题")
        print(f"📁 涉及 {len(files_with_issues)} 个文件")
        print("")
        print("💡 建议：运行修复脚本或手动检查这些文件")
    
    return total_issues

if __name__ == '__main__':
    exit_code = main()
    exit(0 if exit_code == 0 else 1)

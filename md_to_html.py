#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import sys
import os

def md_to_html(md_content, title=""):
    # HTML template
    html_template = """<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<style>
body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; max-width: 680px; margin: 0 auto; padding: 20px; line-height: 1.8; color: #333; background: #fff; }}
h1 {{ font-size: 24px; line-height: 1.4; margin-bottom: 24px; }}
h2 {{ font-size: 20px; margin-top: 32px; margin-bottom: 16px; color: #1a1a1a; border-left: 4px solid #07c160; padding-left: 12px; }}
h3 {{ font-size: 18px; margin-top: 24px; margin-bottom: 12px; color: #2a2a2a; }}
p {{ margin: 16px 0; font-size: 16px; }}
blockquote {{ border-left: 3px solid #07c160; margin: 20px 0; padding: 12px 16px; background: #f7f7f7; color: #555; font-style: italic; }}
strong {{ color: #07c160; }}
hr {{ border: none; border-top: 1px solid #eee; margin: 32px 0; }}
em {{ font-style: italic; color: #888; font-size: 14px; }}
ul {{ margin: 16px 0; padding-left: 20px; }}
li {{ margin: 8px 0; }}
code {{ background: #f5f5f5; padding: 2px 4px; border-radius: 3px; font-family: Monaco, Consolas, monospace; }}
</style>
</head>
<body>
{body}
</body>
</html>"""
    
    # Convert markdown to HTML
    html = md_content
    
    # Headers
    html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
    html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
    html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
    
    # Bold text
    html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
    
    # Italic text
    html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
    
    # Blockquotes
    html = re.sub(r'^> (.+)$', r'<blockquote>\1</blockquote>', html, flags=re.MULTILINE)
    
    # Code inline
    html = re.sub(r'`([^`]+)`', r'<code>\1</code>', html)
    
    # Horizontal rules
    html = re.sub(r'^---$', r'<hr>', html, flags=re.MULTILINE)
    
    # Lists (simple)
    html = re.sub(r'^- (.+)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    html = re.sub(r'(<li>.*</li>)', r'<ul>\1</ul>', html, flags=re.DOTALL)
    html = html.replace('</li>\n<li>', '</li><li>')
    html = html.replace('</ul>\n<ul>', '')
    
    # Paragraphs - split by double newlines and wrap non-tag lines in <p>
    lines = html.split('\n')
    result_lines = []
    in_paragraph = False
    
    for line in lines:
        line = line.strip()
        if not line:
            if in_paragraph:
                result_lines.append('</p>')
                in_paragraph = False
            continue
        
        # Check if line is already an HTML tag
        if line.startswith('<'):
            if in_paragraph:
                result_lines.append('</p>')
                in_paragraph = False
            result_lines.append(line)
        else:
            if not in_paragraph:
                result_lines.append('<p>')
                in_paragraph = True
            else:
                result_lines.append('<br>')
            result_lines.append(line)
    
    if in_paragraph:
        result_lines.append('</p>')
    
    body = '\n'.join(result_lines)
    
    return html_template.format(title=title, body=body)

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 md_to_html.py <markdown_file>")
        sys.exit(1)
    
    md_file = sys.argv[1]
    
    if not os.path.exists(md_file):
        print(f"File not found: {md_file}")
        sys.exit(1)
    
    # Read markdown content
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Extract title from first h1
    title_match = re.search(r'^# (.+)$', md_content, re.MULTILINE)
    title = title_match.group(1) if title_match else "Article"
    
    # Convert to HTML
    html_content = md_to_html(md_content, title)
    
    # Write HTML file
    html_file = md_file.replace('.md', '.html')
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print(f"Converted {md_file} to {html_file}")

if __name__ == "__main__":
    main()
#!/usr/bin/env python3
import re
import sys

def convert_md_to_html(md_content, title, date, audio_file):
    # Extract the main title from the first line
    first_line = md_content.split('\n')[0]
    main_title = first_line.replace('# ', '') if first_line.startswith('# ') else title
    
    # Remove markdown headers and convert to HTML
    content = md_content
    
    # Convert headers
    content = re.sub(r'^# (.+)$', r'<h1>\1</h1>', content, flags=re.MULTILINE)
    content = re.sub(r'^## (.+)$', r'<h2>\1</h2>', content, flags=re.MULTILINE)
    
    # Convert bold text
    content = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', content)
    
    # Convert italic text
    content = re.sub(r'\*([^*]+)\*', r'<em>\1</em>', content)
    
    # Convert horizontal rules
    content = re.sub(r'^---+$', '<hr>', content, flags=re.MULTILINE)
    
    # Convert paragraphs (split by double newlines)
    paragraphs = content.split('\n\n')
    html_paragraphs = []
    
    for para in paragraphs:
        para = para.strip()
        if not para:
            continue
        if para.startswith('<h') or para.startswith('<hr>'):
            html_paragraphs.append(para)
        else:
            # Handle multi-line paragraphs
            para = para.replace('\n', ' ')
            html_paragraphs.append(f'<p>{para}</p>')
    
    content_html = '\n'.join(html_paragraphs)
    
    # HTML template
    html_template = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{main_title} | 明治维新事件篇</title>
    <style>
        body {{ font-family: "PingFang SC", "Microsoft YaHei", sans-serif; line-height: 1.8; max-width: 800px; margin: 0 auto; padding: 20px; color: #333; background: #fafafa; }}
        .header {{ text-align: center; padding: 30px 0; border-bottom: 2px solid #e0e0e0; margin-bottom: 30px; }}
        .header h1 {{ color: #d32f2f; font-size: 2.2em; margin-bottom: 10px; }}
        .header .meta {{ color: #666; font-size: 0.95em; }}
        .back-link {{ margin-bottom: 20px; }}
        .back-link a {{ color: #1976d2; text-decoration: none; font-weight: bold; }}
        .back-link a:hover {{ text-decoration: underline; }}
        .content {{ background: white; padding: 40px; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.1); }}
        .content h1 {{ color: #d32f2f; font-size: 1.8em; margin: 30px 0 15px 0; border-left: 4px solid #d32f2f; padding-left: 15px; }}
        .content h2 {{ color: #1976d2; font-size: 1.4em; margin: 25px 0 12px 0; }}
        .content p {{ margin-bottom: 16px; text-align: justify; }}
        .content hr {{ border: none; border-top: 1px solid #eee; margin: 25px 0; }}
        .content em {{ font-style: italic; color: #666; display: block; text-align: center; margin: 20px 0; border-left: 3px solid #999; padding-left: 15px; }}
        .audio-player {{ background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center; }}
        .audio-player h3 {{ margin: 0 0 15px 0; color: #333; }}
        .audio-player audio {{ width: 100%%; max-width: 500px; }}
    </style>
</head>
<body>
    <div class="back-link">
        <a href="index.html">← 返回事件篇目录</a> | <a href="../index.html">← 返回明治维新人物志</a>
    </div>
    
    <div class="header">
        <h1>{main_title}</h1>
        <div class="meta">
            <strong>{date}</strong> | 江户无血开城
        </div>
    </div>

    <div class="audio-player">
        <h3>🎧 音频版本</h3>
        <audio controls>
            <source src="{audio_file}" type="audio/mpeg">
            您的浏览器不支持音频播放。
        </audio>
        <p><small>建议配合音频一起阅读，体验说书人的讲述风格</small></p>
    </div>

    <div class="content">
        {content_html}
    </div>

    <div class="back-link" style="margin-top: 50px; text-align: center;">
        <a href="index.html">← 返回事件篇目录</a> | <a href="../index.html">← 返回明治维新人物志</a>
    </div>
</body>
</html>'''
    
    return html_template

if __name__ == '__main__':
    # Read the markdown file
    with open('../static-site/meiji/events/event-01-江户无血开城.md', 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # Convert to HTML
    html_content = convert_md_to_html(
        md_content, 
        "江户无血开城：一场茶话会救了百万人",
        "庆応4年4月11日（1868年4月11日）",
        "event-01-江户无血开城.mp3"
    )
    
    # Write HTML file
    with open('../static-site/meiji/events/event-01-江户无血开城.html', 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print("HTML file generated successfully!")
#!/usr/bin/env python3
"""
toutiao-publish.py — Markdown → 头条号草稿 (via Playwright MCP + mcporter)

Usage:
  Single:  python3 toutiao-publish.py <markdown_file> <title>
  Batch:   python3 toutiao-publish.py --batch <dir> [--limit N]
           (reads title from first # heading in each .md file)

Requires: mcporter + playwright MCP (--extension mode)
Chrome must be logged into mp.toutiao.com
Does NOT publish — saves as draft only.
"""

import subprocess
import json
import sys
import re
import time
from pathlib import Path


def mcporter_call(tool: str, **kwargs) -> str:
    """Call a playwright MCP tool via mcporter and return raw output."""
    args = ["mcporter", "call", f"playwright.{tool}"]
    for k, v in kwargs.items():
        args.append(f"{k}={v}")
    result = subprocess.run(args, capture_output=True, text=True, timeout=120)
    return result.stdout + result.stderr


def mcporter_run_code(code: str) -> str:
    """Run Playwright code snippet via mcporter."""
    args = ["mcporter", "call", "playwright.browser_run_code", f"code={code}"]
    result = subprocess.run(args, capture_output=True, text=True, timeout=120)
    return result.stdout + result.stderr


def get_title_from_md(filepath: Path) -> str:
    """Extract first # heading from markdown, truncate to 30 chars."""
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("# "):
                title = line[2:].strip()
                return title[:30]
    return filepath.stem[:30]


def publish_one(md_file: Path, title: str) -> bool:
    """Publish a single markdown file as Toutiao draft."""
    if len(title) < 2 or len(title) > 30:
        print(f"  ❌ Title must be 2-30 chars (got {len(title)}): {title}")
        return False

    md_content = md_file.read_text(encoding="utf-8")
    md_json = json.dumps(md_content)
    title_json = json.dumps(title)

    print(f"📄 {md_file.name} → 草稿")
    print(f"📝 {title}")

    # Step 1: Load markdown into Markdown Studio
    output = mcporter_call("browser_navigate", url="https://md.gptgen.xyz/")
    if "Page URL" not in output:
        print("  ❌ Failed to open md.gptgen.xyz")
        return False
    time.sleep(2)

    mcporter_run_code(f"""async (page) => {{
  const ta = page.locator('textarea').first();
  await ta.fill({md_json});
  await page.waitForTimeout(2000);
  return 'ok';
}}""")

    # Step 2: Get HTML → Toutiao → fill title → paste → save draft
    code = f"""async (page) => {{
  const html = await page.evaluate(() => {{
    const p = document.getElementById('preview');
    return p ? p.innerHTML : null;
  }});
  if (!html) return JSON.stringify({{error: 'no preview HTML'}});

  await page.goto('https://mp.toutiao.com/profile_v4/graphic/publish');
  await page.waitForSelector('[contenteditable]', {{timeout: 10000}});
  await page.waitForTimeout(3000);

  await page.getByRole('textbox', {{name: '请输入文章标题'}}).fill({title_json});

  await page.evaluate((h) => {{
    const ed = document.querySelector('[contenteditable]');
    ed.focus();
    const cd = new DataTransfer();
    cd.setData('text/html', h);
    cd.setData('text/plain', h.replace(/<[^>]+>/g, ''));
    ed.dispatchEvent(new ClipboardEvent('paste', {{bubbles:true, cancelable:true, clipboardData:cd}}));
  }}, html);
  await page.waitForTimeout(2000);

  try {{
    const btn = page.locator('span').filter({{hasText: /^引用AI$/}});
    if (await btn.count() > 0) await btn.first().click();
  }} catch(e) {{}}

  await page.waitForTimeout(3000);

  const info = await page.evaluate(() => {{
    const t = document.body.innerText;
    const m = t.match(/共 (\\d+) 字/);
    return {{words: m ? m[1] : '?', saved: t.includes('草稿已保存')}};
  }});
  return JSON.stringify(info);
}}"""

    result = mcporter_run_code(code)

    if "saved" in result and "true" in result:
        words_match = re.search(r'"words"\s*:\s*"?(\d+)', result)
        words = words_match.group(1) if words_match else "?"
        print(f"  ✅ 草稿已保存 ({words}字)")
        return True
    else:
        print("  ⚠️  可能还在保存，手动检查草稿箱")
        return False


def main():
    args = sys.argv[1:]

    if not args:
        print(__doc__)
        sys.exit(1)

    if args[0] == "--batch":
        batch_dir = Path(args[1]) if len(args) > 1 else None
        if not batch_dir or not batch_dir.is_dir():
            print(f"❌ Directory not found: {args[1] if len(args) > 1 else '(missing)'}")
            sys.exit(1)

        limit = 999
        if "--limit" in args:
            idx = args.index("--limit")
            limit = int(args[idx + 1]) if idx + 1 < len(args) else 999

        md_files = sorted(batch_dir.glob("*.md"))
        print(f"🔄 Batch: {batch_dir} ({len(md_files)} files, limit {limit})")
        print("===")

        ok, fail = 0, 0
        for f in md_files[:limit]:
            title = get_title_from_md(f)
            if publish_one(f, title):
                ok += 1
            else:
                fail += 1
            print("---")
            time.sleep(2)

        print(f"=== Done: {ok} saved, {fail} failed")
    else:
        md_file = Path(args[0])
        title = args[1] if len(args) > 1 else get_title_from_md(md_file)

        if not md_file.is_file():
            print(f"❌ File not found: {md_file}")
            sys.exit(1)

        publish_one(md_file, title)
        print("---")
        print(f"🔗 https://mp.toutiao.com/profile_v4/manage/draft")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Bing Image Creator - automated via Playwright + Edge profile.

Uses Edge's user data directory (separate profile to avoid lock conflict).

First run: use --login to manually log in and save state.
After that: uses saved profile automatically.

Usage:
    python3 bing-image-gen.py --login
    python3 bing-image-gen.py "a futuristic city at sunset" -o ./images
"""

import argparse
import os
import sys
import time
import shutil
import urllib.request
from pathlib import Path
from playwright.sync_api import sync_playwright

PROFILE_DIR = os.path.expanduser("~/.openclaw/bing-creator-profile")
EDGE_USER_DATA = os.path.expanduser("~/Library/Application Support/Microsoft Edge")


def login_flow():
    """Open Edge for manual login, then save auth state."""
    with sync_playwright() as p:
        context = p.chromium.launch_persistent_context(
            user_data_dir=PROFILE_DIR,
            channel="msedge",
            headless=False,
            args=["--disable-blink-features=AutomationControlled"],
        )
        page = context.pages[0] if context.pages else context.new_page()
        page.goto("https://www.bing.com/images/create", wait_until="domcontentloaded")

        print("=== Please log in to your Microsoft account ===")
        print("After you see the Image Creator page, press Enter here...")
        input()

        context.close()
        print(f"Profile saved to {PROFILE_DIR}")


def generate_image(prompt: str, output_dir: str = "./images", timeout_sec: int = 180, headed: bool = False):
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    if not os.path.exists(PROFILE_DIR):
        print("No profile found. Run with --login first.")
        sys.exit(1)

    with sync_playwright() as p:
        context = p.chromium.launch_persistent_context(
            user_data_dir=PROFILE_DIR,
            channel="msedge",
            headless=not headed,
            args=["--disable-blink-features=AutomationControlled"],
        )
        page = context.pages[0] if context.pages else context.new_page()

        print(f"[1/4] Navigating to Bing Image Creator...")
        page.goto("https://www.bing.com/images/create", wait_until="domcontentloaded", timeout=30000)
        time.sleep(3)

        # Type prompt
        print(f"[2/4] Entering prompt: {prompt[:80]}...")
        textarea = page.locator("#sb_form_q, textarea[name='q'], input[name='q']")
        textarea.first.fill(prompt)
        time.sleep(1)

        # Click create
        create_btn = page.locator("#create_btn_c, #create_btn, a#create_btn_c")
        create_btn.first.click()

        # Wait for images
        print(f"[3/4] Waiting for generation (up to {timeout_sec}s)...")
        start = time.time()

        while time.time() - start < timeout_sec:
            imgs = page.locator(".img_cont img, .mimg, .dgr_chrg img, img.mimg")
            count = imgs.count()

            if count > 0:
                first_src = imgs.first.get_attribute("src") or ""
                if first_src and ("th.bing.com" in first_src or "bing.com" in first_src):
                    time.sleep(2)
                    break

            error = page.locator(".gil_err_mt, .gi_err_card, #gilen_son")
            if error.count() > 0:
                try:
                    err_text = error.first.inner_text()
                    print(f"Error from Bing: {err_text}")
                except:
                    print("Error from Bing")
                page.screenshot(path=str(output_path / "debug_error.png"))
                context.close()
                return []

            time.sleep(5)
        else:
            print("Timeout waiting for generation")
            page.screenshot(path=str(output_path / "debug_timeout.png"))
            context.close()
            return []

        # Download
        print(f"[4/4] Downloading images...")
        downloaded = []

        imgs = page.locator(".img_cont img, .mimg, .dgr_chrg img, img.mimg")
        count = imgs.count()

        for i in range(min(count, 4)):
            try:
                img = imgs.nth(i)
                src = img.get_attribute("src") or ""
                if not src or "data:" in src:
                    continue

                filename = output_path / f"bing_gen_{int(time.time())}_{i+1}.jpg"
                req = urllib.request.Request(src, headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(req) as resp:
                    with open(filename, "wb") as f:
                        f.write(resp.read())

                downloaded.append(str(filename))
                print(f"  Downloaded: {filename}")
            except Exception as e:
                print(f"  Failed image {i+1}: {e}")

        context.close()
        return downloaded


def main():
    parser = argparse.ArgumentParser(description="Generate images with Bing Image Creator")
    parser.add_argument("prompt", nargs="?", help="Image generation prompt")
    parser.add_argument("--output", "-o", default="./images", help="Output directory")
    parser.add_argument("--timeout", "-t", type=int, default=180, help="Timeout seconds")
    parser.add_argument("--login", action="store_true", help="Login to Microsoft")
    parser.add_argument("--headed", action="store_true", help="Show browser")
    args = parser.parse_args()

    if args.login:
        login_flow()
        return

    if not args.prompt:
        parser.error("prompt is required (unless using --login)")

    results = generate_image(args.prompt, args.output, args.timeout, args.headed)

    if results:
        print(f"\nSuccess! {len(results)} images saved:")
        for r in results:
            print(f"  {r}")
    else:
        print("\nNo images downloaded.")
        sys.exit(1)


if __name__ == "__main__":
    main()

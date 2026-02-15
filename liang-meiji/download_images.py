#!/usr/bin/env python3
import urllib.request
import os

def download_image(url, filename):
    try:
        urllib.request.urlretrieve(url, filename)
        print(f"Downloaded: {filename}")
        return True
    except Exception as e:
        print(f"Failed to download {filename}: {e}")
        return False

# Create images directory
os.makedirs("images/event-01-无血开城", exist_ok=True)

# Image URLs (Wikimedia Commons, public domain)
images = [
    {
        "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Saigo_Takamori_Portrait_by_Ishikawa_Shizumasa.jpg/800px-Saigo_Takamori_Portrait_by_Ishikawa_Shizumasa.jpg",
        "filename": "images/event-01-无血开城/cover-saigo-takamori.jpg",
        "description": "西乡隆盛画像"
    },
    {
        "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Honmaru_Tatsumi_yagura_of_Edo_Castle_in_1868.jpg/800px-Honmaru_Tatsumi_yagura_of_Edo_Castle_in_1868.jpg",
        "filename": "images/event-01-无血开城/mid-edo-castle-1868.jpg", 
        "description": "1868年江户城"
    },
    {
        "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Katsu_Kaishu.jpg/600px-Katsu_Kaishu.jpg",
        "filename": "images/event-01-无血开城/mid-katsu-kaishu.jpg",
        "description": "胜海舟画像"
    }
]

print("Downloading images...")
for img in images:
    success = download_image(img["url"], img["filename"])
    if success:
        print(f"  {img['description']}: {img['filename']}")

print("Image download completed.")
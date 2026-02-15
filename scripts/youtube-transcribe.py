#!/usr/bin/env python3
"""
YouTube video transcriber using yt-dlp + mlx-whisper (Apple Silicon GPU).

Usage:
    python3 youtube-transcribe.py "https://youtube.com/watch?v=xxx" -o /tmp/output
    python3 youtube-transcribe.py "https://youtube.com/watch?v=xxx" --summary
"""

import argparse
import os
import subprocess
import sys
import tempfile
import json


def download_audio(url: str, output_dir: str) -> str:
    """Download audio from YouTube using yt-dlp."""
    output_template = os.path.join(output_dir, "%(title)s.%(ext)s")
    cmd = [
        "yt-dlp", "-x", "--audio-format", "mp3",
        "-o", output_template,
        "--no-playlist",
        url
    ]
    print(f"[1/3] Downloading audio...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error downloading: {result.stderr}")
        sys.exit(1)

    # Find the downloaded file
    for f in os.listdir(output_dir):
        if f.endswith(".mp3"):
            path = os.path.join(output_dir, f)
            size_mb = os.path.getsize(path) / (1024 * 1024)
            print(f"  Downloaded: {f} ({size_mb:.1f}MB)")
            return path

    print("Error: No mp3 file found after download")
    sys.exit(1)


def transcribe(audio_path: str, model: str = "mlx-community/whisper-small-mlx", language: str = "zh") -> str:
    """Transcribe audio using mlx-whisper."""
    print(f"[2/3] Transcribing with mlx-whisper ({model})...")
    import mlx_whisper
    result = mlx_whisper.transcribe(audio_path, language=language, path_or_hf_repo=model)
    text = result["text"]
    print(f"  Transcribed: {len(text)} chars")
    return text


def main():
    parser = argparse.ArgumentParser(description="Transcribe YouTube videos")
    parser.add_argument("url", help="YouTube video URL")
    parser.add_argument("--output", "-o", default=None, help="Output directory")
    parser.add_argument("--model", "-m", default="mlx-community/whisper-small-mlx",
                        help="MLX whisper model (default: small)")
    parser.add_argument("--language", "-l", default="zh", help="Language code")
    parser.add_argument("--keep-audio", action="store_true", help="Keep downloaded audio")
    args = parser.parse_args()

    output_dir = args.output or tempfile.mkdtemp(prefix="yt-transcribe-")
    os.makedirs(output_dir, exist_ok=True)

    # Download
    audio_path = download_audio(args.url, output_dir)

    # Transcribe
    text = transcribe(audio_path, args.model, args.language)

    # Save
    transcript_path = os.path.splitext(audio_path)[0] + ".txt"
    with open(transcript_path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"[3/3] Saved transcript: {transcript_path}")

    # Cleanup audio if not keeping
    if not args.keep_audio:
        os.remove(audio_path)
        print(f"  Removed audio file")

    # Print transcript
    print(f"\n{'='*60}")
    print(text[:3000])
    if len(text) > 3000:
        print(f"\n... ({len(text) - 3000} more chars)")
    print(f"{'='*60}")
    print(f"\nFull transcript: {transcript_path}")


if __name__ == "__main__":
    main()

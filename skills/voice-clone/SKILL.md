---
name: voice-clone
description: Clone a voice from audio samples and generate speech. Uses ElevenLabs API (requires ELEVENLABS_API_KEY) for professional quality voice cloning and TTS. Supports voice profile creation from audio files, text-to-speech with cloned voices, and podcast segment generation.
version: 0.1.0
---

# Voice Clone Skill

Clone voices from audio samples and generate podcast-quality speech.

## Prerequisites

- **ElevenLabs API key**: Set `ELEVENLABS_API_KEY` environment variable
- **sag** CLI (already installed at `/opt/homebrew/bin/sag`)
- **ffmpeg** (already installed) for audio processing
- **curl** for API calls

## Quick Start

### 1. Clone a Voice from Audio Sample(s)

```bash
# From a local file
bash skills/voice-clone/scripts/voice-clone.sh create "MyVoice" /path/to/sample1.mp3 /path/to/sample2.wav

# From a URL (downloads first)
bash skills/voice-clone/scripts/voice-clone.sh create "MyVoice" https://example.com/voice-sample.mp3
```

ElevenLabs recommends 1-30 minutes of clean audio. Multiple files improve quality.

### 2. Generate Speech with Cloned Voice

```bash
# Simple TTS
bash skills/voice-clone/scripts/voice-clone.sh speak "MyVoice" "Hello, this is my cloned voice!" /tmp/output.mp3

# From a text file
bash skills/voice-clone/scripts/voice-clone.sh speak "MyVoice" @/path/to/script.txt /tmp/output.mp3
```

### 3. Generate Podcast Segment

```bash
# Two-voice podcast conversation
bash skills/voice-clone/scripts/voice-clone.sh podcast /path/to/script.json /tmp/podcast.mp3
```

Script format (`script.json`):
```json
[
  {"voice": "VoiceA", "text": "Welcome to the show!"},
  {"voice": "VoiceB", "text": "Thanks for having me."},
  {"voice": "VoiceA", "text": "Let's dive into today's topic..."}
]
```

### 4. List Available Voices

```bash
bash skills/voice-clone/scripts/voice-clone.sh list
# or simply: sag voices --api-key $ELEVENLABS_API_KEY
```

### 5. Delete a Cloned Voice

```bash
bash skills/voice-clone/scripts/voice-clone.sh delete <voice_id>
```

## Agent Usage

When a user asks to clone a voice:

1. Get their audio sample (file path or URL)
2. Ask for a name for the voice profile
3. Run `voice-clone.sh create "<name>" <file(s)>`
4. Confirm success and the voice ID
5. Use `voice-clone.sh speak` or `sag speak -v "<name>"` for TTS

When generating podcasts:
1. Create a script JSON with voice assignments
2. Run `voice-clone.sh podcast` to generate the full audio
3. Output is a single MP3 file with all segments concatenated

## ElevenLabs Voice Cloning Notes

- **Instant Voice Cloning**: Available on all paid plans. Uses 1-5 short samples.
- **Professional Voice Cloning**: Requires Creator+ plan. Uses 30+ minutes of audio for highest quality.
- This skill uses **Instant Voice Cloning** by default.
- Supported input formats: mp3, wav, m4a, ogg, flac, webm
- Best results: clear speech, minimal background noise, consistent volume

## File Locations

- Scripts: `skills/voice-clone/scripts/`
- Voice profiles cached: `skills/voice-clone/profiles/` (local metadata only; voices live on ElevenLabs)

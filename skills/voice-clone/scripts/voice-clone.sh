#!/usr/bin/env bash
set -euo pipefail

# Voice Clone Skill - ElevenLabs Voice Cloning & TTS
# Requires: ELEVENLABS_API_KEY, curl, ffmpeg, jq

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/../profiles"
mkdir -p "$PROFILES_DIR"

API_KEY="${ELEVENLABS_API_KEY:-}"
BASE_URL="https://api.elevenlabs.io/v1"

die() { echo "ERROR: $*" >&2; exit 1; }

check_key() {
  [[ -n "$API_KEY" ]] || die "ELEVENLABS_API_KEY not set. Get one at https://elevenlabs.io"
}

# Download URL to temp file if needed
resolve_file() {
  local input="$1"
  if [[ "$input" == http* ]]; then
    local tmp="/tmp/voice-clone-$(date +%s)-$(basename "$input" | head -c 50)"
    echo "Downloading $input..." >&2
    curl -sL "$input" -o "$tmp" || die "Failed to download $input"
    echo "$tmp"
  else
    [[ -f "$input" ]] || die "File not found: $input"
    echo "$input"
  fi
}

# ---- Commands ----

cmd_create() {
  local name="${1:?Usage: voice-clone.sh create <name> <file1> [file2] ...}"
  shift
  [[ $# -ge 1 ]] || die "Provide at least one audio file"
  check_key

  # Build multipart form
  local form_args=(-F "name=$name" -F "remove_background_noise=true")
  local labels='{"accent":"neutral"}'
  form_args+=(-F "labels=$labels")

  for f in "$@"; do
    local resolved
    resolved=$(resolve_file "$f")
    form_args+=(-F "files=@$resolved")
  done

  echo "Creating voice clone '$name' with $# sample(s)..."
  local response
  response=$(curl -s -w "\n%{http_code}" \
    -X POST "$BASE_URL/voices/add" \
    -H "xi-api-key: $API_KEY" \
    "${form_args[@]}")

  local http_code body
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$http_code" != "200" ]]; then
    die "API error ($http_code): $body"
  fi

  local voice_id
  voice_id=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin)['voice_id'])" 2>/dev/null || echo "")

  if [[ -z "$voice_id" ]]; then
    die "Failed to parse voice_id from response: $body"
  fi

  # Save profile locally
  echo "$body" | python3 -m json.tool > "$PROFILES_DIR/${name}.json" 2>/dev/null || true

  echo "✅ Voice '$name' created successfully!"
  echo "   Voice ID: $voice_id"
  echo "   Profile saved to: $PROFILES_DIR/${name}.json"
  echo ""
  echo "Generate speech: voice-clone.sh speak \"$name\" \"Hello world\" /tmp/output.mp3"
}

cmd_speak() {
  local voice_name="${1:?Usage: voice-clone.sh speak <voice_name> <text|@file> <output.mp3>}"
  local text_input="${2:?Provide text or @filepath}"
  local output="${3:?Provide output file path}"
  check_key

  # Handle @file input
  local text
  if [[ "$text_input" == @* ]]; then
    local textfile="${text_input:1}"
    [[ -f "$textfile" ]] || die "Text file not found: $textfile"
    text=$(cat "$textfile")
  else
    text="$text_input"
  fi

  # Find voice ID by name
  local voice_id
  voice_id=$(find_voice_id "$voice_name")

  echo "Generating speech with voice '$voice_name' ($voice_id)..."

  local payload
  payload=$(python3 -c "
import json, sys
print(json.dumps({
    'text': sys.argv[1],
    'model_id': 'eleven_v3',
    'voice_settings': {
        'stability': 0.5,
        'similarity_boost': 0.75,
        'style': 0.5,
        'use_speaker_boost': True
    }
}))
" "$text")

  local http_code
  http_code=$(curl -s -w "%{http_code}" -o "$output" \
    -X POST "$BASE_URL/text-to-speech/$voice_id" \
    -H "xi-api-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload")

  if [[ "$http_code" != "200" ]]; then
    local err_body
    err_body=$(cat "$output" 2>/dev/null || echo "unknown")
    die "TTS API error ($http_code): $err_body"
  fi

  local size
  size=$(du -h "$output" | cut -f1)
  echo "✅ Audio saved to: $output ($size)"
}

cmd_podcast() {
  local script_file="${1:?Usage: voice-clone.sh podcast <script.json> <output.mp3>}"
  local output="${2:?Provide output file path}"
  check_key

  [[ -f "$script_file" ]] || die "Script file not found: $script_file"

  local tmpdir="/tmp/voice-clone-podcast-$$"
  mkdir -p "$tmpdir"

  local count
  count=$(python3 -c "import json; print(len(json.load(open('$script_file'))))")

  echo "Generating $count podcast segments..."

  local concat_list="$tmpdir/concat.txt"
  > "$concat_list"

  for i in $(seq 0 $((count - 1))); do
    local voice text segment
    voice=$(python3 -c "import json; d=json.load(open('$script_file')); print(d[$i]['voice'])")
    text=$(python3 -c "import json; d=json.load(open('$script_file')); print(d[$i]['text'])")
    segment="$tmpdir/seg_$(printf '%03d' $i).mp3"

    echo "  [$((i+1))/$count] $voice: ${text:0:50}..."
    cmd_speak "$voice" "$text" "$segment" 2>/dev/null

    echo "file '$segment'" >> "$concat_list"

    # Add small silence between segments
    local silence="$tmpdir/silence_$(printf '%03d' $i).mp3"
    ffmpeg -y -f lavfi -i anullsrc=r=44100:cl=mono -t 0.5 -q:a 9 "$silence" 2>/dev/null
    echo "file '$silence'" >> "$concat_list"
  done

  echo "Concatenating segments..."
  ffmpeg -y -f concat -safe 0 -i "$concat_list" -c copy "$output" 2>/dev/null

  rm -rf "$tmpdir"

  local size
  size=$(du -h "$output" | cut -f1)
  echo "✅ Podcast saved to: $output ($size)"
}

cmd_list() {
  check_key
  echo "Fetching voices..."
  curl -s "$BASE_URL/voices" -H "xi-api-key: $API_KEY" | \
    python3 -c "
import sys, json
data = json.load(sys.stdin)
for v in data.get('voices', []):
    cat = v.get('category', '?')
    tag = '🔵' if cat == 'cloned' else '⚪'
    print(f\"{tag} {v['name']:30s} {v['voice_id']:24s} [{cat}]\")
" 2>/dev/null || die "Failed to list voices"
}

cmd_delete() {
  local voice_id="${1:?Usage: voice-clone.sh delete <voice_id>}"
  check_key

  echo "Deleting voice $voice_id..."
  local http_code
  http_code=$(curl -s -w "%{http_code}" -o /dev/null \
    -X DELETE "$BASE_URL/voices/$voice_id" \
    -H "xi-api-key: $API_KEY")

  [[ "$http_code" == "200" ]] && echo "✅ Deleted." || die "Delete failed ($http_code)"
}

# Helper: resolve voice name to ID
find_voice_id() {
  local name="$1"

  # Check local profile first
  if [[ -f "$PROFILES_DIR/${name}.json" ]]; then
    local vid
    vid=$(python3 -c "import json; print(json.load(open('$PROFILES_DIR/${name}.json'))['voice_id'])" 2>/dev/null || echo "")
    if [[ -n "$vid" ]]; then echo "$vid"; return; fi
  fi

  # Search API
  local vid
  vid=$(curl -s "$BASE_URL/voices" -H "xi-api-key: $API_KEY" | \
    python3 -c "
import sys, json
name = sys.argv[1]
data = json.load(sys.stdin)
for v in data.get('voices', []):
    if v['name'].lower() == name.lower():
        print(v['voice_id'])
        break
" "$name" 2>/dev/null || echo "")

  [[ -n "$vid" ]] || die "Voice '$name' not found. Run 'voice-clone.sh list' to see available voices."
  echo "$vid"
}

# ---- Main ----
cmd="${1:-help}"
shift || true

case "$cmd" in
  create)  cmd_create "$@" ;;
  speak)   cmd_speak "$@" ;;
  podcast) cmd_podcast "$@" ;;
  list)    cmd_list ;;
  delete)  cmd_delete "$@" ;;
  help|*)
    cat <<EOF
Voice Clone Skill - ElevenLabs Voice Cloning & TTS

Usage:
  voice-clone.sh create <name> <file1> [file2] ...   Create voice from samples
  voice-clone.sh speak <voice> <text|@file> <out.mp3> Generate speech
  voice-clone.sh podcast <script.json> <out.mp3>      Generate podcast
  voice-clone.sh list                                  List all voices
  voice-clone.sh delete <voice_id>                     Delete a voice

Environment:
  ELEVENLABS_API_KEY    Required. Your ElevenLabs API key.

Examples:
  voice-clone.sh create "Andy" ~/voice-sample.mp3
  voice-clone.sh speak "Andy" "Hello world" /tmp/hello.mp3
  voice-clone.sh speak "Andy" @script.txt /tmp/narration.mp3
EOF
    ;;
esac

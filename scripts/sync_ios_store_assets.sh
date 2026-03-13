#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  sync_ios_store_assets.sh [--locale <locale>] [--source-ios <dir>] [--source-ipad <dir>] [--skip-ipad]

Exports App Store screenshot assets into:
  native-ios/fastlane/screenshots/<locale>/

By default this script builds the large-iPhone set from the tracked marketing
captures under docs/assets/app/ios and, when available, copies iPad captures
from docs/assets/app/ipad or image-submission-ipad.
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCALE="en-US"
SOURCE_IOS=""
SOURCE_IPAD=""
SKIP_IPAD=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --locale) LOCALE="$2"; shift 2 ;;
    --source-ios) SOURCE_IOS="$2"; shift 2 ;;
    --source-ipad) SOURCE_IPAD="$2"; shift 2 ;;
    --skip-ipad) SKIP_IPAD=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$SOURCE_IOS" ]]; then
  if [[ -d "$ROOT_DIR/image-submission-ios" ]]; then
    SOURCE_IOS="$ROOT_DIR/image-submission-ios"
  else
    SOURCE_IOS="$ROOT_DIR/docs/assets/app/ios"
  fi
fi

if [[ -z "$SOURCE_IPAD" ]]; then
  if [[ -d "$ROOT_DIR/image-submission-ipad" ]]; then
    SOURCE_IPAD="$ROOT_DIR/image-submission-ipad"
  else
    SOURCE_IPAD="$ROOT_DIR/docs/assets/app/ipad"
  fi
fi

TARGET_DIR="$ROOT_DIR/native-ios/fastlane/screenshots/$LOCALE"
mkdir -p "$TARGET_DIR"

shopt -s nullglob
rm -f "$TARGET_DIR"/*.png "$TARGET_DIR"/*.jpg "$TARGET_DIR"/*.jpeg
shopt -u nullglob

if [[ ! -d "$SOURCE_IOS" ]]; then
  echo "iPhone screenshot source directory not found: $SOURCE_IOS" >&2
  exit 1
fi

export_large_iphone() {
  local src="$1"
  local dest="$2"
  cp "$src" "$dest"
  local width
  local height
  width="$(sips -g pixelWidth "$dest" 2>/dev/null | awk -F': ' '/pixelWidth/{print $2}')"
  height="$(sips -g pixelHeight "$dest" 2>/dev/null | awk -F': ' '/pixelHeight/{print $2}')"
  if [[ "$width" != "1242" || "$height" != "2688" ]]; then
    sips --resampleWidth 1242 "$dest" >/dev/null
    sips --cropToHeightWidth 2688 1242 "$dest" >/dev/null
  fi
}

resolve_source_file() {
  local dir="$1"
  shift
  local candidate
  for candidate in "$@"; do
    if [[ -f "$dir/$candidate" ]]; then
      printf '%s\n' "$dir/$candidate"
      return 0
    fi
  done
  return 1
}

copy_if_present() {
  local src="$1"
  local dest="$2"
  if [[ -f "$src" ]]; then
    cp "$src" "$dest"
  fi
}

export_large_iphone "$(resolve_source_file "$SOURCE_IOS" home.png 01-home.png)" "$TARGET_DIR/01-home.png"
export_large_iphone "$(resolve_source_file "$SOURCE_IOS" story-library.png 02-story-library.png)" "$TARGET_DIR/02-story-library.png"
export_large_iphone "$(resolve_source_file "$SOURCE_IOS" story-reader.png 03-story-reader.png)" "$TARGET_DIR/03-story-reader.png"
export_large_iphone "$(resolve_source_file "$SOURCE_IOS" rosary-hub.png 04-rosary-hub.png)" "$TARGET_DIR/04-rosary-hub.png"
export_large_iphone "$(resolve_source_file "$SOURCE_IOS" rosary-set.png 05-rosary-set.png)" "$TARGET_DIR/05-rosary-set.png"

if [[ $SKIP_IPAD -eq 0 ]]; then
  if [[ -d "$SOURCE_IPAD" ]]; then
    if ipad_home="$(resolve_source_file "$SOURCE_IPAD" 01-home.png home.png 2>/dev/null)"; then
      copy_if_present "$ipad_home" "$TARGET_DIR/11-ipad-home.png"
    fi
    if ipad_story_library="$(resolve_source_file "$SOURCE_IPAD" 02-story-library.png story-library.png 2>/dev/null)"; then
      copy_if_present "$ipad_story_library" "$TARGET_DIR/12-ipad-story-library.png"
    fi
    if ipad_story_reader="$(resolve_source_file "$SOURCE_IPAD" 03-story-reader.png story-reader.png 2>/dev/null)"; then
      copy_if_present "$ipad_story_reader" "$TARGET_DIR/13-ipad-story-reader.png"
    fi
    if ipad_rosary_hub="$(resolve_source_file "$SOURCE_IPAD" 04-rosary-hub.png rosary-hub.png 2>/dev/null)"; then
      copy_if_present "$ipad_rosary_hub" "$TARGET_DIR/14-ipad-rosary-hub.png"
    fi
    if ipad_rosary_set="$(resolve_source_file "$SOURCE_IPAD" 05-rosary-set.png rosary-set.png 2>/dev/null)"; then
      copy_if_present "$ipad_rosary_set" "$TARGET_DIR/15-ipad-rosary-set.png"
    fi
  else
    echo "Warning: no iPad screenshot source found at $SOURCE_IPAD" >&2
  fi
fi

echo "Exported App Store assets to $TARGET_DIR"
find "$TARGET_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -print0 \
  | xargs -0 sips -g pixelWidth -g pixelHeight

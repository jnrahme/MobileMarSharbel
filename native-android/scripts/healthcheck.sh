#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

./gradlew --no-daemon clean assembleDebug assembleRelease bundleRelease lint

curl -fsSLI https://marsharbel.com >/dev/null
curl -fsSLI https://marsharbel.com/story.html >/dev/null
curl -fsSLI https://marsharbel.com/media/storybook/images/event-01.png >/dev/null
curl -fsSLI https://marsharbel.com/media/storybook/en-elevenlabs/page-01.mp3 >/dev/null
curl -fsSLI https://marsharbel.com/media/rosary/joyful_1/step-01.mp3 >/dev/null


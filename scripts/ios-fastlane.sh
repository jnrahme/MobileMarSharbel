#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/native-ios"

if [[ ! -d "$IOS_DIR" ]]; then
  echo "native-ios directory not found at $IOS_DIR" >&2
  exit 1
fi

# Prefer Homebrew Ruby over the macOS system Ruby so Bundler can satisfy the
# repo lockfile on a fresh machine.
for ruby_prefix in /opt/homebrew/opt/ruby /opt/homebrew/opt/ruby@3 /usr/local/opt/ruby /usr/local/opt/ruby@3; do
  if [[ -x "$ruby_prefix/bin/ruby" ]]; then
    export PATH="$ruby_prefix/bin:$PATH"
    break
  fi
done

if [[ -f "$IOS_DIR/Gemfile" ]] && command -v bundle >/dev/null 2>&1; then
  cd "$IOS_DIR"
  export BUNDLE_PATH="$IOS_DIR/vendor/bundle"
  export BUNDLE_DISABLE_SHARED_GEMS=true
  export BUNDLE_BIN="$IOS_DIR/vendor/bundle/bin"
  bundle config set --local path "$BUNDLE_PATH" >/dev/null
  bundle config set --local disable_shared_gems true >/dev/null
  if ! bundle check >/dev/null 2>&1; then
    bundle install >/dev/null
  fi
  exec bundle exec fastlane "$@"
fi

if ! command -v fastlane >/dev/null 2>&1; then
  echo "Fastlane is not installed. Install Bundler gems in native-ios or run: gem install fastlane" >&2
  exit 1
fi

cd "$IOS_DIR"
exec fastlane "$@"

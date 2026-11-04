#!/usr/bin/env bash
set -euo pipefail

REPO="NuvioMedia/NuvioDesktop"
CASK="Casks/nuvio.rb"
mkdir -p Casks

JSON="$(curl -fsSL -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$REPO/releases?per_page=1")"
TAG="$(jq -r '.[0].tag_name' <<<"$JSON")"
[[ -n "$TAG" && "$TAG" != "null" ]] || { echo "Could not read release tag"; exit 1; }

CURRENT="$(sed -nE 's/^  version "([^"]+)"/\1/p' "$CASK" 2>/dev/null || true)"
echo "Cask: ${CURRENT:-none}  Latest: $TAG"
if [[ "$TAG" == "$CURRENT" && "${FORCE:-false}" != "true" ]]; then
  echo "Up to date"
  exit 0
fi

URLS="$(jq -r '.[0].assets[].browser_download_url' <<<"$JSON" | grep -Eiv '\.(blockmap|sig|sha256|yml|txt)$' || true)"
MAC="$(grep -Ei '(mac|macos|darwin|osx|\.dmg$)' <<<"$URLS" | grep -Ei '\.(dmg|zip|tar\.gz)$' || true)"
ARM="$(grep -Ei '(arm64|aarch64|apple|silicon)' <<<"$MAC" | head -n1 || true)"
INTEL="$(grep -Ei '(x64|x86_64|amd64|intel)' <<<"$MAC" | grep -Eiv '(arm64|aarch64)' | head -n1 || true)"
UNI="$(grep -Ei 'universal' <<<"$MAC" | head -n1 || true)"
[[ -z "$UNI" ]] && UNI="$(head -n1 <<<"$MAC")"
[[ -z "$ARM" ]] && ARM="$UNI"
[[ -z "$INTEL" ]] && INTEL="$UNI"

if [[ -z "$ARM" || -z "$INTEL" ]]; then
  echo "No macOS asset found. Assets:"
  echo "$URLS"
  exit 1
fi

TMP="$(mktemp -d)"
MNT=""
cleanup() {
  [[ -n "$MNT" ]] && hdiutil detach "$MNT" -quiet -force >/dev/null 2>&1 || true
  rm -rf "$TMP"
}
trap cleanup EXIT

fetch() {
  local f="$TMP/$(basename "$1")"
  [[ -f "$f" ]] || curl -fsSL -o "$f" "$1"
  echo "$f"
}

ARM_FILE="$(fetch "$ARM")"
INTEL_FILE="$(fetch "$INTEL")"
ARM_SHA="$(shasum -a 256 "$ARM_FILE" | cut -d' ' -f1)"
INTEL_SHA="$(shasum -a 256 "$INTEL_FILE" | cut -d' ' -f1)"

X="$TMP/x"
mkdir -p "$X"
case "$ARM_FILE" in
  *.dmg)
    MNT="$X"
    hdiutil attach "$ARM_FILE" -nobrowse -readonly -noautoopen -mountpoint "$X" -quiet
    ;;
  *.zip) ditto -x -k "$ARM_FILE" "$X" ;;
  *.tar.gz) tar -xzf "$ARM_FILE" -C "$X" ;;
esac

APP_PATH="$(find "$X" -maxdepth 3 -type d -name '*.app' -not -path '*/Contents/*' | head -n1)"
[[ -n "$APP_PATH" ]] || { echo "No .app found in $ARM_FILE"; exit 1; }
APP_NAME="$(basename "$APP_PATH")"
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Contents/Info.plist")"

to_cask_url() { sed "s|/download/$TAG/|/download/#{version}/|" <<<"$1"; }
ARM_URL="$(to_cask_url "$ARM")"
INTEL_URL="$(to_cask_url "$INTEL")"

if [[ "$ARM" == "$INTEL" ]]; then
  ARCH_BLOCK="  sha256 \"$ARM_SHA\"

  url \"$ARM_URL\""
else
  ARCH_BLOCK="  on_arm do
    sha256 \"$ARM_SHA\"

    url \"$ARM_URL\"
  end
  on_intel do
    sha256 \"$INTEL_SHA\"

    url \"$INTEL_URL\"
  end"
fi

cat > "$CASK" <<EOF
cask "nuvio" do
  version "$TAG"

$ARCH_BLOCK

  name "Nuvio"
  desc "Nuvio Desktop client"
  homepage "https://github.com/$REPO"

  livecheck do
    url :url
    strategy :github_releases
  end

  app "$APP_NAME"

  uninstall quit: "$BUNDLE_ID"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/$APP_NAME"]
  end
end
EOF

echo "Updated $CASK to $TAG"
cat "$CASK"

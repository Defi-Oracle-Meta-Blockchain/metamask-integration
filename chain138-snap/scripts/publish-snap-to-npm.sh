#!/usr/bin/env bash
# Publish chain138-snap to npm using NPM_ACCESS_TOKEN from .env.
# Token must be a Granular Access Token with "Publish" and "Bypass 2FA for publish" enabled.
# Create at: https://www.npmjs.com/settings/~/tokens → Generate New Token → Granular.
set -e
cd "$(dirname "$0")/.."
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi
if [ -z "$NPM_ACCESS_TOKEN" ]; then
  echo "Error: NPM_ACCESS_TOKEN not set. Add it to .env (see .env.example)." >&2
  exit 1
fi
pnpm run build
# Publish from a temp copy so npm doesn't see parent workspace
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT
cp -r packages/snap/package.json packages/snap/snap.manifest.json packages/snap/README.md packages/snap/dist packages/snap/images "$TMPDIR/"
echo "//registry.npmjs.org/:_authToken=$NPM_ACCESS_TOKEN" > "$TMPDIR/.npmrc"
(cd "$TMPDIR" && npm publish --access public --ignore-scripts --userconfig ./.npmrc)

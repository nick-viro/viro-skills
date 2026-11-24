#!/bin/sh
# skills/ is the source of truth. Codex installs plugins/viro/ as a unit, so
# the skills are copied there (not symlinked: an installed copy must not
# point back into the repo). Run after editing any skill; CI checks they match.
set -eu
cd "$(dirname "$0")/.."
rm -rf plugins/viro/skills
cp -R skills plugins/viro/skills
echo "synced skills/ -> plugins/viro/skills/"

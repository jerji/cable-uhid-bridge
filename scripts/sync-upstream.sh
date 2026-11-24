#!/usr/bin/env bash
# Keep this fork exactly one commit ahead of upstream.
#
#   ./scripts/sync-upstream.sh          # rebase onto upstream/main, force-push fork
#   ./scripts/sync-upstream.sh --check  # only report the distance, change nothing
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if ! git remote get-url upstream >/dev/null 2>&1; then
    git remote add upstream https://github.com/baseman70/cable-uhid-bridge.git
fi

git fetch --quiet upstream

ahead=$(git rev-list --count upstream/main..HEAD)
behind=$(git rev-list --count HEAD..upstream/main)
echo "ahead of upstream/main: ${ahead} commit(s)"
echo "behind upstream/main:  ${behind} commit(s)"

if [ "${1:-}" = "--check" ]; then
    [ "$ahead" -eq 1 ] && [ "$behind" -eq 0 ]
    exit
fi

if [ "$behind" -gt 0 ]; then
    git rebase upstream/main
fi

ahead=$(git rev-list --count upstream/main..HEAD)
if [ "$ahead" -ne 1 ]; then
    echo "refusing to push: ${ahead} commits ahead of upstream (expected exactly 1)" >&2
    echo "squash with: git reset --soft upstream/main && git commit" >&2
    exit 1
fi

git push --force-with-lease fork HEAD:refs/heads/main
git push --force-with-lease fork HEAD:refs/heads/hardening
echo "fork is 1 commit ahead of upstream/main ($(git rev-parse --short HEAD))"

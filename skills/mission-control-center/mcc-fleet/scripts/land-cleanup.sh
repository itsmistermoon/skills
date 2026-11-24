#!/usr/bin/env bash
# Check that a clean worktree's changes landed; cleanup remains with its owner.
set -euo pipefail
wt=$(cd "$1" && pwd -P)
branch=${2:-main}
branch=${branch#origin/}
base=origin/$branch
git -C "$wt" fetch origin "$branch:refs/remotes/origin/$branch"
if [ -n "$(git -C "$wt" status --porcelain)" ]; then
  echo "worktree has uncommitted changes; nothing touched" >&2; exit 1
fi
merged=$(git -C "$wt" merge-tree --write-tree "$base" HEAD)
if [ "$merged" != "$(git -C "$wt" rev-parse "$base^{tree}")" ]; then
  echo "branch has changes missing from $base; nothing touched" >&2; exit 1
fi
echo "branch landed in $base; follow the backend cleanup procedure"

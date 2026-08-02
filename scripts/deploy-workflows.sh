#!/usr/bin/env bash
# Distributes the evidence caller workflow to the organisation's repositories.
#
# It opens a pull request per repository rather than pushing to a default
# branch: a workflow that appears in someone's repository without review is a
# workflow nobody trusts. Repositories that already have the caller are skipped.
set -euo pipefail

org="${EVIDENCE_ORG:-OpenResilienceInitiative}"
branch="chore/pr-evidence-workflow"
caller=".github/workflows/pr-evidence-caller.yml"
source_caller="$(cd "$(dirname "$0")/.." && pwd)/$caller"
dry_run="${DRY_RUN:-0}"

test -f "$source_caller" || { echo "caller workflow not found at $source_caller" >&2; exit 1; }
command -v gh >/dev/null || { echo "gh is required" >&2; exit 1; }

repositories=("$@")
if [ ${#repositories[@]} -eq 0 ]; then
  echo "usage: $0 <repo> [repo...]   (names without the org prefix)" >&2
  echo "       DRY_RUN=1 $0 …        to see what would happen" >&2
  exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

for name in "${repositories[@]}"; do
  echo "== $org/$name"
  if gh api "repos/$org/$name/contents/$caller" >/dev/null 2>&1; then
    echo "   already has the caller; skipping"
    continue
  fi
  if [ "$dry_run" = "1" ]; then
    echo "   would open a pull request adding $caller"
    continue
  fi

  target="$work/$name"
  gh repo clone "$org/$name" "$target" -- --depth 1 >/dev/null 2>&1
  base=$(gh repo view "$org/$name" --json defaultBranchRef --jq .defaultBranchRef.name)
  # ORISO repositories take pull requests against pre-dev, not the default branch.
  if git -C "$target" ls-remote --exit-code --heads origin pre-dev >/dev/null 2>&1; then base="pre-dev"; fi

  git -C "$target" fetch origin "$base" --depth 1 >/dev/null 2>&1
  git -C "$target" checkout -B "$branch" "origin/$base" >/dev/null 2>&1
  install -d "$target/.github/workflows"
  cp "$source_caller" "$target/$caller"
  git -C "$target" add "$caller"
  git -C "$target" -c user.name="evidence-rollout" -c user.email="noreply@dreambau.com" \
    commit -q -m "chore: publish verification evidence to the pull request

Adds the organisation's reusable evidence workflow. It runs after this
repository's own tests rather than instead of them, and does nothing until
ORISO_EVIDENCE_TOKEN is configured.

Evidence links appear as one comment per run on the pull request under test."
  git -C "$target" push -q -u origin "$branch"
  gh pr create --repo "$org/$name" --base "$base" --head "$branch" \
    --title "chore: publish verification evidence to the pull request" \
    --body "Adds the organisation's reusable evidence workflow (\`.github/workflows/pr-evidence-caller.yml\`).

- Runs **after** this repository's own tests, never instead of them.
- Independent of CodeRabbit and any other review automation.
- Does nothing until \`ORISO_EVIDENCE_TOKEN\` is configured, so merging it cannot break CI.
- Publishes at most one comment per run; a scheduled run with no pull request stays a private draft.

Adjust \`project\` and \`environment\` in the caller if this repository is not ORISO/pre-dev." \
    >/dev/null
  echo "   pull request opened against $base"
done
echo "done"

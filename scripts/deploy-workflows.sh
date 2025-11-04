#!/bin/bash

# Deploy workflows to all ORISO repositories
# Goal: Automatically deploy PR validation and template sync workflows to all 16 repos

set -e

ORG="OpenResilienceInitiative"
REPOS=(
  "ORISO-Admin" "ORISO-AgencyService" "ORISO-ConsultingTypeService"
  "ORISO-Database" "ORISO-Docs" "ORISO-Element" "ORISO-Frontend"
  "ORISO-HealthDashboard" "ORISO-Keycloak" "ORISO-Kubernetes"
  "ORISO-Matrix" "ORISO-Nginx" "ORISO-Redis" "ORISO-SignOZ"
  "ORISO-TenantService" "ORISO-UserService"
)

# Find templates
REPO_ROOT="${GITHUB_WORKSPACE:-$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}")")")}"
PR_VALIDATION_TEMPLATE="$REPO_ROOT/.github/workflows/pr-validation-caller.yml"
TEMPLATE_SYNC_TEMPLATE="$REPO_ROOT/.github/workflows/template-sync-caller.yml"
[ ! -f "$PR_VALIDATION_TEMPLATE" ] && { echo "❌ PR validation template not found"; exit 1; }
[ ! -f "$TEMPLATE_SYNC_TEMPLATE" ] && { echo "❌ Template sync template not found"; exit 1; }

# Setup
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT
export GITHUB_TOKEN=${ORG_GITHUB_TOKEN:-$GITHUB_TOKEN}

# Deploy to each repo
SUCCESS=0
for repo in "${REPOS[@]}"; do
  echo "📦 $repo"
  gh repo clone "$ORG/$repo" "$TEMP_DIR/$repo" -- --quiet || continue
  cd "$TEMP_DIR/$repo"
  
  # Deploy workflows, remove old configs
  mkdir -p .github/workflows
  cp "$PR_VALIDATION_TEMPLATE" .github/workflows/pr-validation.yml
  cp "$TEMPLATE_SYNC_TEMPLATE" .github/workflows/template-sync.yml
  rm -f .github/pr-labeler.yml .github/size-labeler.yml
  
  # Skip if no changes
  git diff --quiet && git diff --cached --quiet && { echo "✅ Up to date"; SUCCESS=$((SUCCESS+1)); continue; }
  
  # Commit and push
  git checkout -b chore/add-workflows 2>/dev/null || git checkout chore/add-workflows
  git add .github/
  git commit -m "chore: Add PR validation and template sync workflows" -q
  
  # Push to main, fallback to PR
  if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
    echo "✅ Deployed"
  else
    git push -u origin chore/add-workflows 2>/dev/null
    gh pr create --title "chore: Add PR validation and template sync workflows" --body "Automated." --base main --head chore/add-workflows 2>/dev/null
    gh pr merge chore/add-workflows --auto --squash 2>/dev/null || true
    echo "✅ PR created"
  fi
  SUCCESS=$((SUCCESS+1))
  cd - > /dev/null
done

echo -e "\n✅ Deployed to $SUCCESS/${#REPOS[@]} repositories"

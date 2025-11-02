#!/bin/bash

# Deploy PR validation workflow to all ORISO repositories
# Goal: Automatically deploy .github/workflows/pr-validation.yml to all 16 repos

set -e

ORG="OpenResilienceInitiative"
REPOS=(
  "ORISO-Admin" "ORISO-AgencyService" "ORISO-ConsultingTypeService"
  "ORISO-Database" "ORISO-Docs" "ORISO-Element" "ORISO-Frontend"
  "ORISO-HealthDashboard" "ORISO-Keycloak" "ORISO-Kubernetes"
  "ORISO-Matrix" "ORISO-Nginx" "ORISO-Redis" "ORISO-SignOZ"
  "ORISO-TenantService" "ORISO-UserService"
)

# Find template: .github/workflows/pr-validation-caller.yml
REPO_ROOT="${GITHUB_WORKSPACE:-$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}")")")}"
WORKFLOW_TEMPLATE="$REPO_ROOT/.github/workflows/pr-validation-caller.yml"
[ ! -f "$WORKFLOW_TEMPLATE" ] && { echo "❌ Template not found"; exit 1; }

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
  
  # Deploy workflow, remove old configs
  mkdir -p .github/workflows
  cp "$WORKFLOW_TEMPLATE" .github/workflows/pr-validation.yml
  rm -f .github/pr-labeler.yml .github/size-labeler.yml
  
  # Skip if no changes
  git diff --quiet && git diff --cached --quiet && { echo "✅ Up to date"; SUCCESS=$((SUCCESS+1)); continue; }
  
  # Commit and push
  git checkout -b chore/add-pr-validation-workflow 2>/dev/null || git checkout chore/add-pr-validation-workflow
  git add .github/
  git commit -m "chore: Add PR validation workflow" -q
  
  # Push to main, fallback to PR
  if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
    echo "✅ Deployed"
  else
    git push -u origin chore/add-pr-validation-workflow 2>/dev/null
    gh pr create --title "chore: Add PR validation workflow" --body "Automated." --base main --head chore/add-pr-validation-workflow 2>/dev/null
    gh pr merge chore/add-pr-validation-workflow --auto --squash 2>/dev/null || true
    echo "✅ PR created"
  fi
  SUCCESS=$((SUCCESS+1))
  cd - > /dev/null
done

echo -e "\n✅ Deployed to $SUCCESS/${#REPOS[@]} repositories"

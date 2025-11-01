#!/bin/bash

# Deploy Workflows and Config Files to All ORISO Repositories
# This script copies PR validation workflows and config files to all repositories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Organization name
ORG="OpenResilienceInitiative"

# List of all ORISO repositories (excluding .github and .github-private)
REPOS=(
  "ORISO-Admin"
  "ORISO-AgencyService"
  "ORISO-ConsultingTypeService"
  "ORISO-Database"
  "ORISO-Docs"
  "ORISO-Element"
  "ORISO-Frontend"
  "ORISO-HealthDashboard"
  "ORISO-Keycloak"
  "ORISO-Kubernetes"
  "ORISO-Matrix"
  "ORISO-Nginx"
  "ORISO-Redis"
  "ORISO-SignOZ"
  "ORISO-TenantService"
  "ORISO-UserService"
)

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_DIR="$(dirname "$SCRIPT_DIR")"
WORKFLOW_TEMPLATE="$GITHUB_DIR/.github/workflows/pr-validation-caller.yml"
PR_LABELER_CONFIG="$GITHUB_DIR/pr-labeler.yml"
SIZE_LABELER_CONFIG="$GITHUB_DIR/size-labeler.yml"

# Temporary directory for cloning
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${BLUE}🚀 Deploying workflows and config files to all ORISO repositories...${NC}\n"

# Check if files exist
if [ ! -f "$WORKFLOW_TEMPLATE" ]; then
  echo -e "${RED}❌ Error: Workflow template not found: $WORKFLOW_TEMPLATE${NC}"
  exit 1
fi

if [ ! -f "$PR_LABELER_CONFIG" ]; then
  echo -e "${RED}❌ Error: PR labeler config not found: $PR_LABELER_CONFIG${NC}"
  exit 1
fi

if [ ! -f "$SIZE_LABELER_CONFIG" ]; then
  echo -e "${RED}❌ Error: Size labeler config not found: $SIZE_LABELER_CONFIG${NC}"
  exit 1
fi

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
  echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed.${NC}"
  echo -e "${YELLOW}Install it from: https://cli.github.com/${NC}"
  exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
  echo -e "${YELLOW}⚠️  Not authenticated with GitHub CLI.${NC}"
  echo -e "${BLUE}Please run: gh auth login${NC}"
  exit 1
fi

SUCCESS_COUNT=0
FAILED_REPOS=()

# Process each repository
for repo in "${REPOS[@]}"; do
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}📦 Processing: ${ORG}/${repo}${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  
  REPO_DIR="$TEMP_DIR/$repo"
  
  # Clone repository
  echo -e "${YELLOW}📥 Cloning repository...${NC}"
  if ! gh repo clone "$ORG/$repo" "$REPO_DIR" -- --quiet; then
    echo -e "${RED}❌ Failed to clone ${repo}${NC}"
    FAILED_REPOS+=("$repo")
    continue
  fi
  
  cd "$REPO_DIR"
  
  # Create .github/workflows directory if it doesn't exist
  mkdir -p .github/workflows
  
  # Copy workflow file
  echo -e "${YELLOW}📋 Copying PR validation workflow...${NC}"
  cp "$WORKFLOW_TEMPLATE" .github/workflows/pr-validation.yml
  
  # Create .github directory if needed (for config files)
  mkdir -p .github
  
  # Copy config files
  echo -e "${YELLOW}⚙️  Copying PR labeler config...${NC}"
  cp "$PR_LABELER_CONFIG" .github/pr-labeler.yml
  
  echo -e "${YELLOW}⚙️  Copying size labeler config...${NC}"
  cp "$SIZE_LABELER_CONFIG" .github/size-labeler.yml
  
  # Check if there are changes
  if git diff --quiet && git diff --cached --quiet; then
    echo -e "${GREEN}✅ ${repo}: No changes needed (files already exist and are up to date)${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    continue
  fi
  
  # Commit changes
  echo -e "${YELLOW}💾 Committing changes...${NC}"
  git add .github/workflows/pr-validation.yml .github/pr-labeler.yml .github/size-labeler.yml
  
  # Create or checkout a branch for the changes
  BRANCH_NAME="chore/add-pr-validation-workflow"
  if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
    git checkout $BRANCH_NAME
  else
    git checkout -b $BRANCH_NAME
  fi
  
  git commit -m "chore: Add PR validation workflow and config files

- Add reusable PR validation workflow from organization .github
- Add PR labeler configuration
- Add size labeler configuration

This enables automated PR validation, labeling, and quality checks
across all ORISO repositories."

  # Push changes
  echo -e "${YELLOW}🚀 Pushing changes...${NC}"
  if git push -u origin $BRANCH_NAME; then
    echo -e "${GREEN}✅ ${repo}: Successfully deployed workflows${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    
    # Create PR
    echo -e "${YELLOW}📝 Creating pull request...${NC}"
    if gh pr create \
      --title "chore: Add PR validation workflow and config files" \
      --body "## 🎯 Purpose

This PR adds the standardized PR validation workflow and configuration files to this repository.

## 📋 Changes

- ✅ Added PR validation workflow (calls reusable workflow from \`.github\` repository)
- ✅ Added PR labeler configuration (\`.github/pr-labeler.yml\`)
- ✅ Added size labeler configuration (\`.github/size-labeler.yml\`)

## 🔍 What This Enables

Once merged, all PRs in this repository will automatically:

- ✅ Validate semantic PR titles (feat:, fix:, etc.)
- ✅ Validate PR body completeness
- ✅ Auto-label PRs (work type, area, priority, size)
- ✅ Run security scans (Trivy)
- ✅ Perform code quality checks

## 📚 Documentation

For more details, see:
- [PR Template Setup Guide](https://github.com/OpenResilienceInitiative/.github/blob/main/PR_TEMPLATE_SETUP_GUIDE.md)
- [Label Setup Guide](https://github.com/OpenResilienceInitiative/.github/blob/main/LABEL_SETUP_GUIDE.md)

## ✅ Checklist

- [x] Workflow files copied
- [x] Config files copied
- [x] Ready for review" \
      --base main \
      --head $BRANCH_NAME 2>/dev/null || echo -e "${YELLOW}⚠️  PR might already exist or could not be created automatically${NC}"; then
      echo -e "${GREEN}✅ Pull request created${NC}"
    fi
  else
    echo -e "${RED}❌ Failed to push changes to ${repo}${NC}"
    FAILED_REPOS+=("$repo")
  fi
  
  cd - > /dev/null
done

# Summary
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Deployment Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Successfully processed: ${SUCCESS_COUNT}/${#REPOS[@]} repositories${NC}"

if [ ${#FAILED_REPOS[@]} -gt 0 ]; then
  echo -e "${RED}❌ Failed repositories (${#FAILED_REPOS[@]}):${NC}"
  for repo in "${FAILED_REPOS[@]}"; do
    echo -e "  - ${repo}"
  done
  exit 1
else
  echo -e "${GREEN}🎉 All repositories processed successfully!${NC}"
  echo -e "\n${YELLOW}📝 Next Steps:${NC}"
  echo -e "  1. Review and merge the pull requests in each repository"
  echo -e "  2. Verify workflows are active: Go to Actions tab in each repo"
  echo -e "  3. Create a test PR to see the workflow in action"
fi


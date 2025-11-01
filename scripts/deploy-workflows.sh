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
# Get the .github repository root directory (parent of scripts directory)
GITHUB_DIR="$(dirname "$SCRIPT_DIR")"
# In GitHub Actions, GITHUB_WORKSPACE is set to the repository root
# For local runs, use GITHUB_DIR (parent of scripts)
GITHUB_REPO_ROOT="${GITHUB_WORKSPACE:-$GITHUB_DIR}"
WORKFLOW_TEMPLATE="$GITHUB_REPO_ROOT/.github/workflows/pr-validation-caller.yml"
PR_LABELER_CONFIG="$GITHUB_REPO_ROOT/pr-labeler.yml"
SIZE_LABELER_CONFIG="$GITHUB_REPO_ROOT/size-labeler.yml"
PR_TEMPLATE_DIR="$GITHUB_REPO_ROOT/pull_request_template"

# Temporary directory for cloning
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${BLUE}🚀 Deploying workflows, config files, and PR templates to all ORISO repositories...${NC}\n"

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

if [ ! -d "$PR_TEMPLATE_DIR" ]; then
  echo -e "${RED}❌ Error: PR template directory not found: $PR_TEMPLATE_DIR${NC}"
  echo -e "${YELLOW}Debug info:${NC}"
  echo -e "  SCRIPT_DIR: $SCRIPT_DIR"
  echo -e "  GITHUB_DIR: $GITHUB_DIR"
  echo -e "  GITHUB_REPO_ROOT: $GITHUB_REPO_ROOT"
  echo -e "  GITHUB_WORKSPACE: ${GITHUB_WORKSPACE:-not set}"
  echo -e "  Current directory: $(pwd)"
  echo -e "  Looking for templates in alternate locations..."
  
  # Try alternate locations
  if [ -d "$GITHUB_DIR/pull_request_template" ]; then
    echo -e "${GREEN}✅ Found templates at: $GITHUB_DIR/pull_request_template${NC}"
    PR_TEMPLATE_DIR="$GITHUB_DIR/pull_request_template"
  elif [ -d "$(pwd)/pull_request_template" ]; then
    echo -e "${GREEN}✅ Found templates at: $(pwd)/pull_request_template${NC}"
    PR_TEMPLATE_DIR="$(pwd)/pull_request_template"
  elif [ -n "$GITHUB_WORKSPACE" ] && [ -d "$GITHUB_WORKSPACE/pull_request_template" ]; then
    echo -e "${GREEN}✅ Found templates at: $GITHUB_WORKSPACE/pull_request_template${NC}"
    PR_TEMPLATE_DIR="$GITHUB_WORKSPACE/pull_request_template"
  else
    echo -e "${RED}❌ Templates not found in any location${NC}"
    echo -e "${YELLOW}Expected locations:${NC}"
    echo -e "  - $PR_TEMPLATE_DIR"
    echo -e "  - $GITHUB_DIR/pull_request_template"
    echo -e "  - $(pwd)/pull_request_template"
    exit 1
  fi
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

# Display authentication info
echo -e "${BLUE}📋 Authentication Info:${NC}"
gh auth status
echo ""

# Test access to organization
echo -e "${YELLOW}🔍 Testing organization access...${NC}"
if gh api orgs/$ORG &>/dev/null; then
  echo -e "${GREEN}✅ Can access organization: ${ORG}${NC}"
else
  echo -e "${RED}❌ Cannot access organization: ${ORG}${NC}"
  echo -e "${YELLOW}⚠️  You may need to use a Personal Access Token (PAT) instead of GITHUB_TOKEN${NC}"
  echo -e "${YELLOW}   Set it as: GITHUB_TOKEN=<your-pat>${NC}"
fi
echo ""

SUCCESS_COUNT=0
FAILED_REPOS=()

# Process each repository
for repo in "${REPOS[@]}"; do
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}📦 Processing: ${ORG}/${repo}${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  
  REPO_DIR="$TEMP_DIR/$repo"
  
  # Check if repository exists and is accessible
  echo -e "${YELLOW}🔍 Checking repository access...${NC}"
  if ! gh repo view "$ORG/$repo" &>/dev/null; then
    echo -e "${RED}❌ Repository ${ORG}/${repo} not found or not accessible${NC}"
    echo -e "${YELLOW}   Possible reasons:${NC}"
    echo -e "${YELLOW}   - Repository doesn't exist${NC}"
    echo -e "${YELLOW}   - GitHub token doesn't have access${NC}"
    echo -e "${YELLOW}   - Repository is private and requires organization access${NC}"
    FAILED_REPOS+=("$repo")
    continue
  fi
  
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
  
  # Copy PR templates
  echo -e "${YELLOW}📝 Copying PR templates...${NC}"
  mkdir -p .github/pull_request_template
  cp -r "$PR_TEMPLATE_DIR"/* .github/pull_request_template/
  
  # Check if there are changes
  if git diff --quiet && git diff --cached --quiet; then
    echo -e "${GREEN}✅ ${repo}: No changes needed (files already exist and are up to date)${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    continue
  fi
  
  # Commit changes
  echo -e "${YELLOW}💾 Committing changes...${NC}"
  git add .github/workflows/pr-validation.yml .github/pr-labeler.yml .github/size-labeler.yml .github/pull_request_template/
  
  # Create or checkout a branch for the changes
  BRANCH_NAME="chore/add-pr-validation-workflow"
  if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
    git checkout $BRANCH_NAME
  else
    git checkout -b $BRANCH_NAME
  fi
  
  git commit -m "chore: Add PR validation workflow, config files, and PR templates

- Add reusable PR validation workflow from organization .github
- Add PR labeler configuration
- Add size labeler configuration
- Add PR templates (frontend, backend, docs, bugfix, etc.)

This enables automated PR validation, labeling, quality checks, and
standardized PR templates across all ORISO repositories."

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
- ✅ Added PR templates (\`.github/pull_request_template/\`)

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


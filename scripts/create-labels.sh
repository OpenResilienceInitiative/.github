#!/bin/bash

# =============================================================================
# Create Labels Script for ORISO Platform
# =============================================================================
# This script creates all required labels across all ORISO repositories
# Run this in GitHub Codespaces or any environment with GitHub CLI installed
#
# Features:
#   - Prevents duplicate labels (checks existence before creating)
#   - Updates existing labels if they already exist
#   - Safe to run multiple times (idempotent)
#
# Usage:
#   chmod +x create-labels.sh
#   ./create-labels.sh
#
# Or in Codespaces:
#   bash .github/scripts/create-labels.sh
# =============================================================================

# Don't exit on error - we want to continue processing other labels/repos even if one fails
set +e  # Continue on error to process all repositories

ORGANIZATION="OpenResilienceInitiative"

# All repositories that need labels
REPOS=(
    "ORISO-Frontend"
    "ORISO-Admin"
    "ORISO-UserService"
    "ORISO-TenantService"
    "ORISO-AgencyService"
    "ORISO-ConsultingTypeService"
    "ORISO-Database"
    "ORISO-Nginx"
    "ORISO-Keycloak"
    "ORISO-Redis"
    "ORISO-Matrix"
    "ORISO-Element"
    "ORISO-HealthDashboard"
    "ORISO-SignOZ"
    "ORISO-Kubernetes"
    "ORISO-Docs"
    ".github"
)

# Label definitions
declare -a LABELS=(
    # Work Type Labels
    "story|0E8A16|User-facing feature"
    "task|0052CC|Technical work"
    "bug|D73A4A|Bug fix"
    "hotfix|B60205|Urgent production fix"
    
    # Priority Labels
    "P0-Critical|D73A4A|Critical priority"
    "P1-High|FB8500|High priority"
    "P2-Medium|FFB703|Medium priority"
    "P3-Low|06D6A0|Low priority"
    
    # Area/Component Labels
    "frontend|E99695|Frontend changes"
    "backend|7057FF|Backend changes"
    "api|008672|API changes"
    "database|FBCA04|Database changes"
    "infra|F9D0C4|Infrastructure changes"
    "docs|D4C5F9|Documentation"
    
    # Size Labels
    "S|0E8A16|Small: 1-9 files"
    "M|FFB703|Medium: 10-29 files"
    "L|FB8500|Large: 30-99 files"
    "XL|D73A4A|Extra Large: 100+ files"
    
    # State Labels
    "needs-refinement|6A737D|Needs more work"
    "blocked|D73A4A|Blocked by dependency"
    "ready-to-merge|0E8A16|Ready for merge"
    "breaking-change|B60205|Contains breaking changes"
)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI (gh) is not installed.${NC}"
        echo "Please install it: https://cli.github.com"
        exit 1
    fi
    echo -e "${GREEN}✅ GitHub CLI found${NC}"
}

# Function to check authentication
check_auth() {
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not authenticated with GitHub CLI${NC}"
        echo "Running: gh auth login"
        gh auth login --web
    else
        echo -e "${GREEN}✅ Authenticated with GitHub${NC}"
        gh auth status
    fi
}

# Function to create or update a label (simple - tries create, if fails tries update)
create_or_update_label() {
    local REPO=$1
    local NAME=$2
    local COLOR=$3
    local DESC=$4
    local FULL_REPO="$ORGANIZATION/$REPO"
    
    # Try to create first (idempotent - will fail if exists, then we update)
    if [ -z "$DESC" ]; then
        if gh label create "$NAME" --repo "$FULL_REPO" --color "$COLOR" &>/dev/null; then
            return 0
        fi
        # Create failed, try update (label exists)
        gh label edit "$NAME" --repo "$FULL_REPO" --color "$COLOR" &>/dev/null
    else
        if gh label create "$NAME" --repo "$FULL_REPO" --color "$COLOR" --description "$DESC" &>/dev/null; then
            return 0
        fi
        # Create failed, try update (label exists)
        gh label edit "$NAME" --repo "$FULL_REPO" --color "$COLOR" --description "$DESC" &>/dev/null
    fi
}

# Function to create all labels for a repository
create_repo_labels() {
    local REPO=$1
    local SUCCESS=0
    
    echo -e "\n${BLUE}📦 Processing: ${REPO}${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check repository access
    if ! gh repo view "$ORGANIZATION/$REPO" &>/dev/null; then
        echo -e "  ${RED}❌ Cannot access repository${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        return 0  # Continue with other repos
    fi
    
    # Process each label
    for LABEL_DEF in "${LABELS[@]}"; do
        IFS='|' read -r NAME COLOR DESC <<< "$LABEL_DEF"
        
        if create_or_update_label "$REPO" "$NAME" "$COLOR" "$DESC"; then
            echo -e "  ${GREEN}✓${NC} $NAME"
            ((SUCCESS++))
        else
            echo -e "  ${RED}✗${NC} $NAME (failed)"
        fi
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✅ Success: $SUCCESS / ${#LABELS[@]}${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     ORISO Platform - Label Creation Script              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Pre-flight checks
    check_gh_cli
    check_auth
    
    echo -e "\n${BLUE}📋 Repositories to process: ${#REPOS[@]}${NC}"
    echo -e "${BLUE}🏷️  Labels per repository: ${#LABELS[@]}${NC}"
    echo -e "${YELLOW}⏱️  Estimated time: ~2-3 minutes${NC}"
    
    # Ask for confirmation (skip if non-interactive or CI environment)
    if [ -z "$CI" ] && [ -t 0 ]; then
        echo -e "\n${YELLOW}⚠️  This will create labels in ${#REPOS[@]} repositories.${NC}"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Cancelled.${NC}"
            exit 0
        fi
    else
        echo -e "\n${BLUE}Running in non-interactive mode (CI/Automated)${NC}"
    fi
    
    # Process each repository
    local START_TIME=$(date +%s)
    
    for REPO in "${REPOS[@]}"; do
        create_repo_labels "$REPO"
        sleep 0.5  # Small delay to avoid rate limits
    done
    
    local END_TIME=$(date +%s)
    local DURATION=$((END_TIME - START_TIME))
    
    # Final summary
    echo -e "\n${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    Summary                                ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}✅ Completed in ${DURATION} seconds${NC}"
    echo -e "${BLUE}📦 Repositories processed: ${#REPOS[@]}${NC}"
    echo -e "${GREEN}🎉 All done! Labels are ready for your PR workflow.${NC}"
}

# Run main function
main


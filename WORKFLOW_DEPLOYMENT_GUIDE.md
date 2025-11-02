# Workflow Deployment Guide

> **📚 Organization README:** For a complete overview of contributing to ORISO Platform, see [README.md](./README.md)

This guide explains how PR validation workflows are deployed across all ORISO Platform repositories using **reusable workflows**.

## 🎯 Overview

Instead of copying the same workflow file to all 16 repositories, we use GitHub's **reusable workflows** feature:

1. **Reusable workflow** - Defined once in `.github` repository (the "source of truth")
2. **Caller workflow** - Simple file in each repository that calls the reusable workflow
3. **Config files** - Repository-specific configs (labeler settings) that must exist in each repo

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│  .github Repository (OpenResilienceInitiative/.github) │
│                                                          │
│  workflows/                                             │
│  ├── pr-validation.yml        ← Reusable workflow      │
│  └── deploy-workflows.yml     ← Auto-deployment        │
│                                                          │
│  pr-labeler.yml                                         │
│  size-labeler.yml                                       │
│  scripts/deploy-workflows.sh                           │
└─────────────────────────────────────────────────────────┘
                        │
                        │ Calls
                        ▼
┌─────────────────────────────────────────────────────────┐
│  Individual Repositories (ORISO-*)                      │
│                                                          │
│  .github/workflows/                                     │
│  └── pr-validation.yml     ← Calls reusable workflow   │
│                                                          │
│  .github/                                                │
│  (No config files - auto-fetched from centralized repo) │
└─────────────────────────────────────────────────────────┘
```

## 📋 How It Works

### 1. Reusable Workflow

**Location:** `.github/workflows/pr-validation.yml`

This is the main workflow that performs all PR validation:
- ✅ Semantic PR title validation
- ✅ PR body completeness checks
- ✅ Auto-labeling (work type, area, priority, size)
- ✅ Security scanning (Trivy)
- ✅ Code quality checks

**Key feature:** Defined with `workflow_call:` trigger, making it reusable.

### 2. Caller Workflow (in each repository)

**Location:** `.github/workflows/pr-validation.yml` (in each repo)

Simple workflow that calls the reusable one:

```yaml
name: PR Validation & Quality Checks

on:
  pull_request:
    types: [opened, edited, reopened, synchronize]

jobs:
  validate-and-label:
    uses: OpenResilienceInitiative/.github/.github/workflows/pr-validation.yml@main
```

### 3. Configuration Files (Centralized - NO Local Copies Needed)

**✨ Single Source of Truth:** Config files are automatically fetched from the centralized `.github` repository during workflow execution.

**Centralized Location:** `.github/pr-labeler.yml` and `.github/size-labeler.yml` in the `.github` repository.

**⚠️ Important:** Do NOT create local copies of these files in individual repositories. The workflow fetches them automatically from the centralized repository. Having local copies defeats the purpose of centralization and creates maintenance burden across 16 repositories.

- `.github/pr-labeler.yml` - Branch-based labeling rules (automatically fetched from centralized repo)
- `.github/size-labeler.yml` - PR size classification (automatically fetched from centralized repo)

**To update configs:** Edit files in `.github` repository → All repositories automatically use updated configs on next PR (no deployment needed!)

## 🚀 Deployment

### ⚠️ Prerequisites

**IMPORTANT**: Before deploying, you must set up a Personal Access Token (PAT):

1. The default `GITHUB_TOKEN` **cannot access private organization repositories**
2. Create a PAT with `repo` scope (see [Setup Guide](./SETUP_WORKFLOW_DEPLOYMENT.md))
3. Add it as `ORG_GITHUB_TOKEN` secret in repository settings

**Without the PAT, deployment will fail with "Repository not found or not accessible" errors.**

📖 **See**: [Setup Workflow Deployment](./SETUP_WORKFLOW_DEPLOYMENT.md) for detailed instructions.

### Automatic Deployment (Fully Automated - No Manual Action Needed)

When you update workflows or configs in `.github` repository:

1. **Push changes** to `.github` repository
2. **Deploy workflow triggers automatically**
3. **Workflows automatically deployed** to all 16 repositories (pushes directly to main)
4. **Done!** No manual PR merging needed

**Workflow:** `.github/workflows/deploy-workflows.yml`

**✨ Fully Automatic:**
- Deploys directly to main branch (no PR creation)
- Falls back to auto-merge PR if branch protection blocks direct push
- Triggers automatically when workflow files change (push-based)
- Manual trigger available via workflow_dispatch if needed
- All changes reflect across all repositories automatically

### Manual Deployment

**Via GitHub Actions:**
1. Go to: `https://github.com/OpenResilienceInitiative/.github`
2. Click **Actions** → **Deploy Workflows to All Repositories**
3. Click **Run workflow** → **Run workflow**

**Via Script:**
```bash
cd .github/scripts
bash deploy-workflows.sh
```

## ✅ What Gets Deployed

When you run the deployment:

| File | Source | Destination | Purpose | Status |
|------|--------|-------------|---------|--------|
| `pr-validation.yml` | `.github/workflows/pr-validation-caller.yml` | `{repo}/.github/workflows/pr-validation.yml` | Calls reusable workflow | **Required** |
| `pr-labeler.yml` | `.github/pr-labeler.yml` | ❌ **NOT DEPLOYED** | Labeling rules | **Centralized - Auto-fetched** |
| `size-labeler.yml` | `.github/size-labeler.yml` | ❌ **NOT DEPLOYED** | Size classification | **Centralized - Auto-fetched** |

**✨ Single Source of Truth:**
- ✅ Config files (`pr-labeler.yml`, `size-labeler.yml`) are **automatically fetched from centralized `.github` repository** during workflow execution
- ✅ **DO NOT create local copies** - This eliminates duplicate maintenance across 16 repositories
- ✅ **Zero deployment needed** - Update once in `.github` repo → All repos use updated configs immediately
- ✅ PR templates are **centralized** in `.github/pull_request_template/` and automatically available to all organization repositories
- ✅ **Automatic deployment** - Workflows push directly to main (no manual PR merging required)

## 📝 Updating Workflows

### Updating the Reusable Workflow

1. **Edit** `.github/workflows/pr-validation.yml`
2. **Push** to `.github` repository
3. **All repositories** automatically use the updated workflow (no redeployment needed!)

### Updating Config Files

**✨ Centralized Update (Recommended):**
1. **Edit** `.github/pr-labeler.yml` or `.github/size-labeler.yml` in the `.github` repository
2. **Push** to `.github` repository
3. **All repositories automatically use updated configs** on next PR (no redeployment needed!)

**Note:** Config files are now centralized and automatically fetched during workflow execution. No need to deploy config file updates to individual repositories!

## 🎯 Benefits of This Approach

✅ **Single Source of Truth** - Update workflow logic once, applies everywhere  
✅ **Maximized Reuse** - Config files (`pr-labeler.yml`, `size-labeler.yml`) automatically fetched from centralized repo  
✅ **Fully Automatic Deployment** - Workflows deploy automatically (direct push to main, no manual PR merging)  
✅ **Version Control** - Changes tracked in `.github` repository  
✅ **Easier Maintenance** - Update configs once in `.github` repo → all repos automatically use updated configs  
✅ **Consistency** - All repos use the same validation rules and labeling configs  
✅ **Centralized Updates** - Improve workflow or configs → automatically benefits all repos on next PR  
✅ **No Redeployment Needed** - Config file changes take effect immediately across all repositories  
✅ **On-Demand Sync** - Triggers automatically on changes, manual trigger available when needed  

## 🔍 Verifying Deployment

After deployment, verify in each repository:

1. **Check workflow exists:**
   ```
   {repo}/.github/workflows/pr-validation.yml
   ```

2. **Verify NO local config files exist** (they shouldn't be there):
   ```bash
   # These should NOT exist - configs are fetched from centralized repo
   ls {repo}/.github/pr-labeler.yml      # Should not exist
   ls {repo}/.github/size-labeler.yml   # Should not exist
   ```
   
   **Note:** Config files are automatically fetched from centralized `.github` repository during workflow execution. Local copies should NOT exist - they create unnecessary duplication across 16 repositories.

3. **Check Actions tab:**
   - Go to repository → **Actions**
   - Workflow should appear in workflow list
   - Create a test PR to verify it runs

## ❓ FAQ

### Q: Do I need to add workflows manually to each repository?

**A:** No! The deployment script does it automatically and pushes directly to main. No manual action needed after initial setup.

### Q: What if I update the reusable workflow?

**A:** Updates automatically apply to all repositories that call it. No redeployment needed.

### Q: What if I need repository-specific validation?

**A:** You can add additional jobs in the caller workflow, or create repository-specific workflows alongside the reusable one.

### Q: Can I customize the workflow for a specific repo?

**A:** Yes, you can modify the caller workflow in individual repositories if needed, but we recommend keeping consistency.

### Q: What happens if a repository already has a workflow?

**A:** The script will update it if the file exists, or create it if it doesn't. It's safe to run multiple times. All deployments are automatic and push directly to main.

### Q: How does automatic deployment work?

**A:** The deployment script:
- Tries to push directly to main branch (fully automatic)
- Falls back to creating PR with auto-merge if branch protection prevents direct push
- Runs weekly on schedule to ensure all repositories stay in sync
- No manual PR review or merging needed

### Q: Which repositories are managed?

**A:** All 16 ORISO repositories are automatically managed:
- ORISO-Admin, ORISO-AgencyService, ORISO-ConsultingTypeService
- ORISO-Database, ORISO-Docs, ORISO-Element, ORISO-Frontend
- ORISO-HealthDashboard, ORISO-Keycloak, ORISO-Kubernetes
- ORISO-Matrix, ORISO-Nginx, ORISO-Redis, ORISO-SignOZ
- ORISO-TenantService, ORISO-UserService

The `.github` repository is excluded as it's the source repository.

## 📚 Related Documentation

- **[README.md](./README.md)** - Organization overview
- **[PR Template Guide](./PR_TEMPLATE_SETUP_GUIDE.md)** - PR template usage
- **[Label Setup Guide](./LABEL_SETUP_GUIDE.md)** - Label system documentation
- **[Scripts README](./scripts/README.md)** - Script documentation

---

*Last Updated: January 2025*


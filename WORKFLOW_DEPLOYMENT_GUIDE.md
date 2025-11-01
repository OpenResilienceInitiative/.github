# Workflow Deployment Guide

> **📚 Organization README:** For a complete overview of contributing to ORISO Platform, see [README.md](./README.md)

This guide explains how PR validation workflows are deployed across all ORISO Platform repositories using **reusable workflows**.

## 🎯 Overview

Instead of copying the same workflow file to all 17 repositories, we use GitHub's **reusable workflows** feature:

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
│  ├── pr-labeler.yml          ← Config (copied)         │
│  └── size-labeler.yml        ← Config (copied)         │
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

### 3. Configuration Files

These must exist in each repository:
- `.github/pr-labeler.yml` - Branch-based labeling rules
- `.github/size-labeler.yml` - PR size classification

## 🚀 Deployment

### ⚠️ Prerequisites

**IMPORTANT**: Before deploying, you must set up a Personal Access Token (PAT):

1. The default `GITHUB_TOKEN` **cannot access private organization repositories**
2. Create a PAT with `repo` scope (see [Setup Guide](./SETUP_WORKFLOW_DEPLOYMENT.md))
3. Add it as `ORG_GITHUB_TOKEN` secret in repository settings

**Without the PAT, deployment will fail with "Repository not found or not accessible" errors.**

📖 **See**: [Setup Workflow Deployment](./SETUP_WORKFLOW_DEPLOYMENT.md) for detailed instructions.

### Automatic Deployment (Recommended)

When you update workflows or configs in `.github` repository:

1. **Push changes** to `.github` repository
2. **Deploy workflow triggers automatically**
3. **Script creates PRs** in all 17 repositories
4. **Review and merge** PRs to activate workflows

**Workflow:** `.github/workflows/deploy-workflows.yml`

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

| File | Source | Destination | Purpose |
|------|--------|-------------|---------|
| `pr-validation.yml` | `.github/workflows/pr-validation-caller.yml` | `{repo}/.github/workflows/pr-validation.yml` | Calls reusable workflow |
| `pr-labeler.yml` | `.github/pr-labeler.yml` | `{repo}/.github/pr-labeler.yml` | Labeling rules |
| `size-labeler.yml` | `.github/size-labeler.yml` | `{repo}/.github/size-labeler.yml` | Size classification |
| `pull_request_template/` | `.github/pull_request_template/` | `{repo}/.github/pull_request_template/` | PR templates (8 templates) |

## 📝 Updating Workflows

### Updating the Reusable Workflow

1. **Edit** `.github/workflows/pr-validation.yml`
2. **Push** to `.github` repository
3. **All repositories** automatically use the updated workflow (no redeployment needed!)

### Updating Config Files

1. **Edit** `.github/pr-labeler.yml` or `.github/size-labeler.yml`
2. **Push** to `.github` repository
3. **Deploy workflow runs automatically**
4. **Review and merge** PRs in each repository

## 🎯 Benefits of This Approach

✅ **Single Source of Truth** - Update workflow logic once, applies everywhere  
✅ **Version Control** - Changes tracked in `.github` repository  
✅ **Easier Maintenance** - No need to update 17 files manually  
✅ **Consistency** - All repos use the same validation rules  
✅ **Centralized Updates** - Improve workflow → automatically benefits all repos  

## 🔍 Verifying Deployment

After deployment, verify in each repository:

1. **Check workflow exists:**
   ```
   {repo}/.github/workflows/pr-validation.yml
   ```

2. **Check configs exist:**
   ```
   {repo}/.github/pr-labeler.yml
   {repo}/.github/size-labeler.yml
   ```

3. **Check Actions tab:**
   - Go to repository → **Actions**
   - Workflow should appear in workflow list
   - Create a test PR to verify it runs

## ❓ FAQ

### Q: Do I need to add workflows manually to each repository?

**A:** No! The deployment script does it automatically. Just run it once.

### Q: What if I update the reusable workflow?

**A:** Updates automatically apply to all repositories that call it. No redeployment needed.

### Q: What if I need repository-specific validation?

**A:** You can add additional jobs in the caller workflow, or create repository-specific workflows alongside the reusable one.

### Q: Can I customize the workflow for a specific repo?

**A:** Yes, you can modify the caller workflow in individual repositories if needed, but we recommend keeping consistency.

### Q: What happens if a repository already has a workflow?

**A:** The script will update it if the file exists, or create it if it doesn't. It's safe to run multiple times.

## 📚 Related Documentation

- **[README.md](./README.md)** - Organization overview
- **[PR Template Guide](./PR_TEMPLATE_SETUP_GUIDE.md)** - PR template usage
- **[Label Setup Guide](./LABEL_SETUP_GUIDE.md)** - Label system documentation
- **[Scripts README](./scripts/README.md)** - Script documentation

---

*Last Updated: January 2025*


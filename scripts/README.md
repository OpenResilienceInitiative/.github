# Organization Scripts

This directory contains utility scripts for managing the Open Resilience Initiative organization and ORISO Platform repositories.

## 📁 Available Scripts

### 🏷️ Label Management

**Script:** `create-labels.sh`

**Purpose:** Creates standardized labels across all ORISO Platform repositories.

**What it does:**
- Creates 22 labels in each of 17 repositories
- Ensures consistent labeling across the organization
- Works with PR validation workflow auto-labeling

**Labels created:**
- **Work Type** (4): `story`, `task`, `bug`, `hotfix`
- **Priority** (4): `P0-Critical`, `P1-High`, `P2-Medium`, `P3-Low`
- **Area** (6): `frontend`, `backend`, `api`, `database`, `infra`, `docs`
- **Size** (4): `S`, `M`, `L`, `XL`
- **State** (4): `needs-refinement`, `blocked`, `ready-to-merge`, `breaking-change`

**Usage:**

**Option 1: Automatic (Recommended)**
- Push the workflow file → Runs automatically
- Go to: Actions → "Create Labels Across Repositories"
- Workflow runs automatically on first push (only runs again if script is updated)

**Option 2: Manual via GitHub Actions**
- Go to: `https://github.com/OpenResilienceInitiative/.github`
- Click **Actions** → **Create Labels Across Repositories**
- Click **Run workflow** → **Run workflow**

**Option 3: GitHub Codespaces**
```bash
gh auth login --web
bash .github/scripts/create-labels.sh
```

**Workflow:** `.github/workflows/create-labels.yml`

**Documentation:** See [LABEL_SETUP_GUIDE.md](../LABEL_SETUP_GUIDE.md) for detailed label information.

---

## 🚀 Running Scripts

### Method 1: GitHub Actions (Automatic)

Most scripts have corresponding GitHub Actions workflows that run automatically:

1. **Script changes trigger workflows** - When you update a script file and push, its workflow runs automatically
2. **No manual intervention needed** - Works completely in GitHub's cloud
3. **One-time setup** - Push once, runs automatically

**Workflows are located in:** `.github/workflows/`

### Method 2: GitHub Codespaces (Interactive)

For interactive script execution:

1. Open any repository in Codespaces
2. Clone the `.github` repository if needed
3. Navigate to script directory
4. Run with appropriate permissions

```bash
# Example
cd .github/scripts
bash create-labels.sh
```

### Method 3: Local Execution

If you have GitHub CLI installed locally:

```bash
gh auth login
bash .github/scripts/[script-name].sh
```

---

## 📝 Adding New Scripts

When adding a new script to this directory:

### 1. Create the Script File

```bash
.github/scripts/
  ├── your-new-script.sh
  └── README.md (this file)
```

### 2. Make it Executable

```bash
chmod +x .github/scripts/your-new-script.sh
```

### 3. Document It

Update this README.md to include:
- Script name and purpose
- What it does
- How to run it
- Any prerequisites
- Corresponding workflow (if applicable)

### 4. Create Workflow (Optional)

If the script should run automatically:

**File:** `.github/workflows/your-new-script.yml`

```yaml
name: Your Script Name

on:
  push:
    paths:
      - '.github/scripts/your-new-script.sh'
    branches:
      - main
      - master
  workflow_dispatch:  # Optional manual trigger

permissions:
  contents: write  # Adjust as needed

jobs:
  run-script:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup prerequisites
        run: |
          # Add any setup steps
          
      - name: Run script
        run: |
          chmod +x .github/scripts/your-new-script.sh
          bash .github/scripts/your-new-script.sh
```

### 5. Update This README

Add a new section following the format above.

---

## 🔒 Script Standards

All scripts in this directory should:

- ✅ Include a header comment with purpose and usage
- ✅ Use `set -e` for error handling (where appropriate)
- ✅ Provide clear output/feedback
- ✅ Handle errors gracefully
- ✅ Support non-interactive mode (for CI/CD)
- ✅ Be documented in this README

### Script Template

```bash
#!/bin/bash

# =============================================================================
# Script Name - Brief Description
# =============================================================================
# Detailed description of what the script does
#
# Usage:
#   bash .github/scripts/script-name.sh
#
# Environment:
#   - CI: Set to run non-interactively
#   - GITHUB_TOKEN: Required for GitHub API access
# =============================================================================

set -e  # Exit on error

# Your script code here
```

---

### 📦 Workflow Deployment

**Script:** `deploy-workflows.sh`

**Purpose:** Deploys PR validation workflows and configuration files to all ORISO Platform repositories.

**What it does:**
- Copies PR validation workflow to each repository
- Copies PR labeler configuration (`.github/pr-labeler.yml`)
- Copies size labeler configuration (`.github/size-labeler.yml`)
- Creates pull requests in each repository for review

**Files deployed:**
- `pr-validation.yml` - Calls the reusable workflow from `.github` repository
- `pr-labeler.yml` - Branch-based labeling configuration
- `size-labeler.yml` - PR size labeling configuration

**Usage:**

**Option 1: Automatic (Recommended)**
- Push workflow files or configs → Runs automatically
- Go to: Actions → "Deploy Workflows to All Repositories"
- Workflow runs automatically when files are updated

**Option 2: Manual via GitHub Actions**
- Go to: `https://github.com/OpenResilienceInitiative/.github`
- Click **Actions** → **Deploy Workflows to All Repositories**
- Click **Run workflow** → **Run workflow**

**Option 3: GitHub Codespaces**
```bash
gh auth login --web
bash .github/scripts/deploy-workflows.sh
```

**Workflow:** `.github/workflows/deploy-workflows.yml`

**Documentation:** See main [README.md](../README.md) for workflow information.

---

## 📋 Script Index

| Script | Purpose | Workflow | Runs When |
|--------|---------|----------|-----------|
| `create-labels.sh` | Create labels across repos | `create-labels.yml` | Script/workflow updated or manual |
| `deploy-workflows.sh` | Deploy workflows and configs to all repos | `deploy-workflows.yml` | Workflow/config files updated or manual |

---

## 🔧 Troubleshooting

### Scripts in GitHub Actions

**Workflow not running?**
- Check if the script file path is in the workflow's `paths` trigger
- Verify Actions are enabled in repository settings
- Check workflow file syntax (YAML valid)

**Script fails?**
- Review workflow logs in Actions tab
- Verify permissions in workflow file
- Check script syntax and error handling

### Scripts in Codespaces

**Permission denied?**
```bash
chmod +x .github/scripts/script-name.sh
```

**Not authenticated?**
```bash
gh auth login --web
```

**Script errors?**
- Run with verbose output: `bash -x script-name.sh`
- Check script syntax: `bash -n script-name.sh`

---

## 📚 Related Documentation

- **[Organization README](../README.md)** - Overview of the organization
- **[Label Setup Guide](../LABEL_SETUP_GUIDE.md)** - Label system documentation
- **[PR Template Guide](../PR_TEMPLATE_SETUP_GUIDE.md)** - PR template usage

---

## 💡 Tips

- **Test scripts locally first** - Use Codespaces for testing before pushing
- **Use non-interactive mode** - Set `CI=true` for automated runs
- **Handle errors gracefully** - Scripts should continue or fail clearly
- **Document changes** - Update this README when adding new scripts
- **Version control** - Scripts are versioned with git, track changes properly

---

*Last Updated: November 2025*

<div align="center">

# 🌐 Open Resilience Initiative

**Organization-wide Standards & Automation**

[![Organization](https://img.shields.io/badge/GitHub-Organization-lightgrey)](https://github.com/OpenResilienceInitiative)

</div>

---

## 📖 About This Repository

**`.github`** is a special repository that defines **reusable workflows and standards** for all repositories in the Open Resilience Initiative. This is not just for PR validation—it's a **framework for all automation** across the organization.

### What This Repository Provides

- 📋 **PR Templates** - Standardized templates for consistent pull requests
- 🐛 **Issue Templates** - Structured issue forms for bug reports, features, docs, and questions
- ⚙️ **Reusable Workflows** - Centralized GitHub Actions for ANY automation need
- 🏷️ **Label Configuration** - Consistent labeling rules across all repositories
- 📚 **Documentation & Templates** - Guidelines for creating new workflows
- 🔄 **Centralized Management** - Update once, apply everywhere automatically

> **💡 Key Principle:** Define workflows **once** in `.github`, use them **everywhere**. This eliminates duplication and ensures consistency across all 16+ repositories.

---

## 🚀 Reusable Workflow Framework

### Current Reusable Workflows

| Workflow | Purpose | Used By |
|----------|---------|---------|
| `pr-validation.yml` | PR validation, labeling, security scanning | All repositories |
| `create-labels.yml` | Create standardized labels | All repositories |
| `deploy-workflows.yml` | Deploy workflows to all repos | This repository only |

### How Reusable Workflows Work

**1. Define workflow in `.github`** (this repository):

```yaml
# .github/.github/workflows/my-workflow.yml
name: My Reusable Workflow

on:
  workflow_call:  # Makes it reusable

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - name: Do something
        run: echo "Works everywhere!"
```

**2. Call it from any repository**:

```yaml
# Any repository: .github/workflows/use-my-workflow.yml
name: Use My Workflow

on:
  push:
    branches: [main]

jobs:
  call-workflow:
    uses: OpenResilienceInitiative/.github/.github/workflows/my-workflow.yml@main
```

**Result:** The workflow runs in that repository automatically!

---

## 📝 Creating New Reusable Workflows

### For New Contributors

Follow this pattern to create ANY new reusable workflow:

#### Step 1: Create the Reusable Workflow

**Location:** `.github/.github/workflows/your-workflow.yml`

```yaml
name: Your Workflow Name (Reusable)

on:
  workflow_call:  # Required: Makes it reusable
    inputs:
      optional-input:
        description: 'Optional input parameter'
        required: false
        type: string

permissions:
  contents: read  # Set minimum required permissions

jobs:
  your-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Your step
        run: |
          echo "This workflow can be used by any repository"
          echo "Input: ${{ inputs.optional-input }}"
```

#### Step 2: Create a Caller Template

**Location:** `.github/.github/workflows/your-workflow-caller.yml`

This is the template that gets deployed to repositories:

```yaml
name: Your Workflow Name

on:
  push:  # Trigger when you need it
    branches: [main]
  workflow_dispatch:  # Optional: Manual trigger

jobs:
  run-workflow:
    uses: OpenResilienceInitiative/.github/.github/workflows/your-workflow.yml@main
    with:
      optional-input: "value"
```

#### Step 3: Deploy to All Repositories

Update `deploy-workflows.sh` to include your new workflow:

```bash
# Add your workflow to the deploy script
REPOS=(...all repos...)
for repo in "${REPOS[@]}"; do
  # Copy your caller template
  cp your-workflow-caller.yml .github/workflows/your-workflow.yml
done
```

**That's it!** Your workflow is now available across all repositories.

---

## 🎯 Use Cases for Reusable Workflows

You can create reusable workflows for:

- ✅ **PR Validation** (already implemented)
- ✅ **CI/CD Pipelines** - Build, test, deploy
- ✅ **Security Scanning** - SAST, dependency checks
- ✅ **Code Quality** - Linting, formatting checks
- ✅ **Documentation** - Auto-generate docs, check links
- ✅ **Label Management** - Create/update labels (already implemented)
- ✅ **Dependency Updates** - Automated dependency management
- ✅ **Release Management** - Automated versioning and releases
- ✅ **Any automation** you need across multiple repos!

**Pattern:** If you need the same automation in multiple repositories, make it a reusable workflow in `.github`!

---

## ✨ Automated Features (Current)

### PR Validation Workflow

All pull requests automatically get:

- ✅ Semantic PR title validation (`feat:`, `fix:`, `docs:`, etc.)
- ✅ PR body completeness checks
- ✅ Auto-labeling (work type, area, priority, size)
- ✅ Security scanning (Trivy)
- ✅ Code quality checks

### How to Use in Your Repository

Just add this file to any repository:

```yaml
# .github/workflows/pr-validation.yml (in any repo)
name: PR Validation & Quality Checks

on:
  pull_request:
    types: [opened, edited, reopened, synchronize]

jobs:
  validate-and-label:
    uses: OpenResilienceInitiative/.github/.github/workflows/pr-validation.yml@main
```

That's it! All PR validation features work automatically.

---

## 📋 Contributing Guidelines

### Creating Your First Reusable Workflow

**1. Plan your workflow:**
   - What problem does it solve?
   - Will it be used by multiple repositories?
   - What triggers should it respond to?

**2. Create the reusable workflow:**
   - File: `.github/.github/workflows/my-workflow.yml`
   - Use `workflow_call:` trigger
   - Set minimum required permissions
   - Keep it simple and focused

**3. Create the caller template:**
   - File: `.github/.github/workflows/my-workflow-caller.yml`
   - Simple wrapper that calls your reusable workflow
   - Deploy this to repositories

**4. Document it:**
   - Add to this README
   - Explain what it does
   - Show example usage

**5. Deploy it:**
   - Update `deploy-workflows.sh` if needed
   - Or deploy manually to specific repos

---

## 🏷️ Labels

Labels are automatically applied via reusable workflows:

| Category | Labels | Auto-detection |
|---------|--------|----------------|
| **Work Type** | `story`, `task`, `bug`, `hotfix` | Branch name |
| **Priority** | `P0-Critical`, `P1-High`, `P2-Medium`, `P3-Low` | PR content |
| **Area** | `frontend`, `backend`, `api`, `database`, `infra`, `docs` | Files changed |
| **Size** | `S`, `M`, `L`, `XL` | File count |

---

## 📚 Documentation

- **[PR Template Guide](./PR_TEMPLATE_SETUP_GUIDE.md)** - How to create proper PRs
- **[Issue Template Guide](./ISSUE_TEMPLATE_SETUP_GUIDE.md)** - How to use and customize issue templates
- **[Label Setup Guide](./LABEL_SETUP_GUIDE.md)** - Understanding our label system
- **[Workflow Deployment Guide](./WORKFLOW_DEPLOYMENT_GUIDE.md)** - How to deploy workflows
- **[Code Review Guide](./CODE_REVIEW_GUIDE.md)** - Review standards

---

## 🔄 Workflow Architecture

```
┌─────────────────────────────────────┐
│  .github Repository                  │
│  (This repository - Source of Truth) │
│                                      │
│  ┌──────────────────────────────┐   │
│  │ Reusable Workflows            │   │
│  │ - pr-validation.yml          │   │
│  │ - create-labels.yml          │   │
│  │ - YOUR-NEW-WORKFLOW.yml      │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │ Caller Templates              │   │
│  │ (deployed to repos)           │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
           ↓ (automatic)
┌─────────────────────────────────────┐
│  All Organization Repositories       │
│  - ORISO-Frontend                   │
│  - ORISO-Backend                    │
│  - ORISO-Docs                       │
│  - ... (16+ repositories)          │
│                                      │
│  Each repo has caller workflows      │
│  that use reusable workflows         │
└─────────────────────────────────────┘
```

**Key Benefits:**
- ✅ Update once → All repos get updates automatically
- ✅ No duplication → Single source of truth
- ✅ Consistency → Same workflow behavior everywhere
- ✅ Easy to add → New repos automatically get workflows

---

## 🌐 Organization

**Open Resilience Initiative** - Building accessible mental health support through open-source technology.

- **Website**: [openresilience.cc](https://openresilience.cc)
- **Documentation**: [Platform Docs](https://openresilienceinitiative.mintlify.app)
- **GitHub**: [@OpenResilienceInitiative](https://github.com/OpenResilienceInitiative)

---

<div align="center">

**Centralized automation framework for all repositories**

[![License](https://img.shields.io/badge/License-AGPL--3.0-green)](LICENSE)

</div>

# PR Template Setup Guide

> **📚 Organization README:** For a complete overview of contributing to ORISO Platform, see [README.md](./README.md)

## 📍 Overview

PR templates are **centralized** in the `.github` repository and automatically available to all organization repositories. This ensures consistency across all 17+ ORISO repositories.

### Current Location

```
.github/
├── PULL_REQUEST_TEMPLATE/          ← Templates directory (CORRECT location)
│   ├── architecture.md
│   ├── backend.md
│   ├── bugfix.md
│   ├── default.md
│   ├── devops.md
│   ├── docs.md
│   ├── frontend.md
│   └── hotfix.md
└── PULL_REQUEST_TEMPLATE.md        ← Default template (auto-populates)
```

## ⚠️ Important Requirements

For organization-wide PR templates to work, follow GitHub's exact specifications:

1. **Repository Name**: Must be exactly `.github` (not `.github-repo` or any variant) ✅

2. **Repository Visibility**: The `.github` repository **must be public** (or accessible to all target repositories) for templates to be accessible organization-wide.

3. **Correct Location**: Templates **must** be at:
   - `PULL_REQUEST_TEMPLATE/` (uppercase, with underscore) ✅ **CURRENT - CORRECT**
   - Located at the **root** of the `.github` repository ✅
   - NOT nested in `.github/.github/` ❌

4. **File Format**: 
   - All templates must be `.md` (Markdown) files ✅
   - Directory name: `PULL_REQUEST_TEMPLATE` (UPPERCASE, underscore)
   - Files are lowercase: `frontend.md`, `backend.md`, etc.

5. **Auto-Availability**: Once pushed to the `.github` repository, templates automatically appear in all organization repositories that don't have their own templates.

## 📋 Available Templates

| Template | Purpose | Use When |
|----------|---------|----------|
| **frontend.md** | UI, components, styles | Changing React/Vue components, CSS, UI features |
| **backend.md** | APIs, services, database | Changing server logic, APIs, database schemas |
| **architecture.md** | Major refactors | Restructuring code, moving modules, redesign |
| **devops.md** | CI/CD, infrastructure | Changing workflows, Docker, Kubernetes, deployments |
| **bugfix.md** | Bug fixes | Fixing reported bugs or regressions |
| **docs.md** | Documentation | Updating README, API docs, guides |
| **hotfix.md** | Urgent production fixes | Critical production issues requiring immediate fix |
| **default.md** | Catch-all | Other types of changes not covered above |

## ✅ How to Use Templates

**Important Note:** Unlike Issue templates, GitHub does **not** provide an automatic template chooser UI for Pull Requests. You need to use query parameters to select templates.

### Method 1: Add Template Parameter to PR URL (Recommended)

1. Create your PR normally: `https://github.com/OpenResilienceInitiative/REPO/compare/main...your-branch`
2. Add template parameter: `?expand=1&template=frontend.md`
3. Full URL: `https://github.com/OpenResilienceInitiative/REPO/compare/main...your-branch?expand=1&template=frontend.md`

**Available Template URLs:**
- **Frontend PRs:** `?expand=1&template=frontend.md`
- **Backend PRs:** `?expand=1&template=backend.md`
- **Docs PRs:** `?expand=1&template=docs.md`
- **Bug Fixes:** `?expand=1&template=bugfix.md`
- **DevOps:** `?expand=1&template=devops.md`
- **Architecture:** `?expand=1&template=architecture.md`
- **Hotfix:** `?expand=1&template=hotfix.md`
- **Default:** `?expand=1&template=default.md`

### Method 2: Use GitHub CLI

```bash
gh pr create --template frontend.md
```

### Method 3: Auto-Populated Default Template

We have **both**:
- ✅ `PULL_REQUEST_TEMPLATE.md` at root - Auto-populates as default template
- ✅ `PULL_REQUEST_TEMPLATE/` directory - Contains 8 specialized templates

**How it works:**
1. When creating a PR, the default template (`PULL_REQUEST_TEMPLATE.md`) auto-populates
2. The default template includes links to other templates
3. Users can manually change the URL to select a different template using query parameters

### Method 4: Create PR Links with Templates Pre-Selected

You can bookmark or share links with templates pre-selected for your team.

## 📝 PR Title Format (Required)

All PR titles **must** follow semantic commit format:

```
<type>: <description>
```

### Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `chore:` - Maintenance tasks
- `refactor:` - Code restructuring
- `docs:` - Documentation changes
- `perf:` - Performance improvements
- `test:` - Test additions/changes
- `ci:` - CI/CD changes

### Examples:
✅ **Good:**
- `feat: Add user authentication with OAuth2`
- `fix: Resolve login validation issue`
- `docs: Improve API documentation`
- `refactor: Simplify service layer architecture`

❌ **Bad:**
- `Add feature` (missing type)
- `Fix bug` (too vague)
- `UPDATE USER SERVICE` (wrong format, all caps)

## 🤖 Automated Features

Our PR automation includes:

### 1. Semantic Title Validation
- Ensures PR titles follow conventional commit format
- Blocks merge if title doesn't match pattern

### 2. Body Completeness Check
- Validates that all checklist items are completed
- Ensures minimum description length (100 chars)
- Checks Summary section is filled out

### 3. Auto Labeling
- Labels based on branch name:
  - `feature/*` or `feat/*` → `feature` label
  - `fix/*` or `bugfix/*` → `fix` label
  - `infra/*` or `devops/*` → `infra` label
  - `docs/*` → `docs` label

### 4. Size Labeling
- Automatically adds size labels:
  - **S** (1-9 files changed)
  - **M** (10-29 files)
  - **L** (30-99 files)
  - **XL** (100+ files)

### 5. Breaking Change Detection
- Automatically adds `breaking-change` label if detected in title/body

### 6. Review Assignment
- Auto-assigns reviewers based on changed files
- Frontend changes → frontend team
- Backend changes → backend team
- DevOps changes → DevOps team

### 7. Quality Checks
- Scans for TODO/FIXME comments (warning)
- Checks for console.log statements (warning)
- Detects potential hardcoded secrets (warning)
- Security vulnerability scanning (Trivy)

### 8. CodeRabbit Integration
- Automated code review by AI
- Code quality suggestions
- Security vulnerability detection
- Best practices recommendations

## ✅ Best Practices

### Before Creating PR:
1. ✅ Ensure all tests pass locally
2. ✅ Follow code style guidelines
3. ✅ Update documentation if needed
4. ✅ Rebase on latest main branch
5. ✅ **Add template parameter to PR URL** (e.g., `?expand=1&template=frontend.md`)

### PR Description:
1. ✅ Select the appropriate template using URL parameter
2. ✅ Fill out Summary section completely
3. ✅ Complete all checklist items
4. ✅ Link related issues using `#issue-number`
5. ✅ Add screenshots/videos for UI changes
6. ✅ Include test results for backend changes

### During Review:
1. ✅ Address CodeRabbit suggestions
2. ✅ Respond to reviewer comments
3. ✅ Update PR if changes requested
4. ✅ Keep PR updated with main branch

### Branch Naming:
Follow the pattern: `<type>/<description>`

**Examples:**
- `feature/user-authentication`
- `fix/login-validation`
- `docs/api-documentation`
- `refactor/service-layer`

## 🔧 Troubleshooting

### Templates Not Showing?

**Check 1: Repository Visibility** ⚠️ **CRITICAL**
```
Verify .github repository is public:
1. Go to: https://github.com/OpenResilienceInitiative/.github/settings
2. Scroll to "Danger Zone" → "Change repository visibility"
3. Must be: ✅ Public (required for org-wide templates)
```

**Check 2: Repository Name**
```
Must be exactly: .github
❌ .github-repo
❌ github-templates
✅ .github
```

**Check 3: Template Location** ✅ **VERIFIED - CORRECT**
```bash
# Current location (CORRECT):
.github/PULL_REQUEST_TEMPLATE/  ✅ Root level, UPPERCASE, underscores

# Wrong locations:
.github/.github/PULL_REQUEST_TEMPLATE/  ❌ Nested (wrong)
pull_request_template/                 ❌ Wrong case (lowercase)
pull-request-template/                 ❌ Wrong separator
```

**Check 4: File Names**
- ✅ All templates are `.md` files
- ✅ Directory name: `PULL_REQUEST_TEMPLATE` (UPPERCASE, underscore)
- ✅ Files are lowercase: `frontend.md`, `backend.md`, etc.

**Check 5: Single Template File Conflict** ⚠️ **CRITICAL**
- **DO NOT** have `PULL_REQUEST_TEMPLATE.md` or `pull_request_template.md` at the root of `.github` repository if you want to use multiple templates
- A single file at root **overrides** the directory-based templates and disables template selection
- **Current Setup:** We have both - the default file auto-populates, and the directory provides specialized templates via URL parameter

**Check 6: Repository Override**
- If a repository has its own `pull_request_template/` directory OR `PULL_REQUEST_TEMPLATE.md` file, it **overrides** organization templates for that specific repository only
- Organization templates apply to all repos **without** local templates

**Check 7: Refresh After Changes**
- After pushing template updates, you may need to refresh or create a new PR draft to see the updated templates

### PR Validation Failing?

**Issue: "Semantic PR title check failed"**
- Fix: Update PR title to follow `type: description` format

**Issue: "PR body completeness check failed"**
- Fix: Complete all checklist items `[ ]` → `[x]`
- Fix: Expand Summary section (minimum 100 chars)
- Fix: Fill in missing template sections

**Issue: "Labels not auto-assigned"**
- Check: Branch name follows expected pattern (`feature/*`, `fix/*`, etc.)
- Check: PR labeler workflow ran successfully

### Need Help?

- Check workflow logs in Actions tab
- Review this guide
- Contact DevOps team for workflow issues
- Contact Tech Lead for review process questions

## 📚 Quick Reference

### PR Creation Flow:
```
Create Branch → Make Changes → Push → Create PR → Select Template → 
Fill Template → Auto-checks Run → CodeRabbit Reviews → Human Reviews → 
Address Feedback → Get Approval → Merge
```

### Template Selection:
```
Standard PR URL: https://github.com/OpenResilienceInitiative/REPO/compare/main...branch
With Template: https://github.com/OpenResilienceInitiative/REPO/compare/main...branch?expand=1&template=frontend.md
```

## 📚 References

- [GitHub: Creating a Pull Request Template](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
- [Organization-Wide Templates](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)

---

*Last Updated: January 2025*

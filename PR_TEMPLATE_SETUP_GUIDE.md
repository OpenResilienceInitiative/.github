# PR Template Setup Guide

> **📚 Organization README:** For a complete overview of contributing to ORISO Platform, see [README.md](./README.md)

## Available Templates

When creating a PR, GitHub will show you all available templates in `.github/PULL_REQUEST_TEMPLATE/`:

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

## PR Title Format (Required)

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
✅ Good:
- `feat: Add user authentication with OAuth2`
- `fix: Resolve login validation issue`
- `docs: Improve API documentation`
- `refactor: Simplify service layer architecture`

❌ Bad:
- `Add feature` (missing type)
- `Fix bug` (too vague)
- `UPDATE USER SERVICE` (wrong format, all caps)

## Automated Features

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

## Best Practices

### Before Creating PR:
1. ✅ Ensure all tests pass locally
2. ✅ Follow code style guidelines
3. ✅ Update documentation if needed
4. ✅ Rebase on latest main branch

### PR Description:
1. ✅ Select the appropriate template
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

Examples:
- `feature/user-authentication`
- `fix/login-validation`
- `docs/api-documentation`
- `refactor/service-layer`

## Troubleshooting

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

## Quick Reference

```
Create Branch → Make Changes → Push → Create PR → Select Template → 
Fill Template → Auto-checks Run → CodeRabbit Reviews → Human Reviews → 
Address Feedback → Get Approval → Merge
```


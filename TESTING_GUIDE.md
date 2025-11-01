# Testing Guide: Workflows, GitHub Setup & CodeRabbit

> **📚 Quick Links:** 
> - [Setup Workflow Deployment](./SETUP_WORKFLOW_DEPLOYMENT.md) - PAT setup
> - [Workflow Deployment Guide](./WORKFLOW_DEPLOYMENT_GUIDE.md) - Deployment details
> - [Code Review Guide](./CODE_REVIEW_GUIDE.md) - CodeRabbit configuration

This guide provides comprehensive testing procedures for:
1. ✅ **GitHub Workflows** - PR validation, deployment, label creation
2. ✅ **GitHub Setup** - Authentication, reusable workflows, configuration
3. ✅ **CodeRabbit** - Automated code review integration

---

## 🎯 Overview

Your `.github` repository includes:
- **PR Validation Workflow** - Validates PRs, auto-labels, security scans
- **Deploy Workflows** - Deploys workflows to all 17 ORISO repositories
- **Create Labels** - Creates standardized labels across repos
- **CodeRabbit Integration** - Automated code reviews (requires GitHub App setup)

---

## 1️⃣ Testing GitHub Workflows

### Prerequisites

✅ **PAT Setup Required:**
1. Create Personal Access Token (PAT) with `repo` and `read:org` scopes
2. Add as `ORG_GITHUB_TOKEN` secret in `.github` repository
3. See [SETUP_WORKFLOW_DEPLOYMENT.md](./SETUP_WORKFLOW_DEPLOYMENT.md) for details

### Test 1: PR Validation Workflow

**What it tests:** Validates PR titles, bodies, auto-labeling, security scans

**Steps:**

1. **Create a test repository or use an existing ORISO repository**
   ```bash
   # If testing in a real repo, create a test branch
   git checkout -b test/workflow-validation
   ```

2. **Create a test PR** with the following:
   - **Title:** `feat: add new user authentication feature`
   - **Body:** Include a detailed description (100+ chars) with completed checklist
   - **Files Changed:** Add/modify some code files

3. **Verify workflow runs:**
   - Go to repository → **Actions** tab
   - Look for "PR Validation & Quality Checks" workflow
   - Should run automatically on PR open/edit

4. **Check workflow results:**
   - ✅ Semantic PR title validation (should pass)
   - ✅ PR body validation (should pass)
   - ✅ Auto-labeling (check PR for labels: `feat`, `story`, size label, etc.)
   - ✅ Security scan (Trivy results)
   - ✅ Code quality checks (TODO/FIXME, console.log checks)

**Expected Output:**
```
✅ PR title validation passed
✅ PR body validation passed
✅ Labels applied: feat, story, S (or appropriate size)
✅ Security scan completed (no critical issues)
✅ Code quality checks passed
```

**Manual Test Cases:**

| Test Case | PR Title | Expected Result |
|-----------|---------|----------------|
| Valid semantic title | `feat: add login page` | ✅ Pass |
| Invalid title | `Add login page` | ❌ Fail - missing type |
| Valid with scope | `fix(api): resolve auth bug` | ✅ Pass |
| Invalid casing | `FEAT: Add feature` | ❌ Fail - uppercase |

### Test 2: Deploy Workflows

**What it tests:** Deployment script creates workflows in all repositories

**Steps:**

1. **Trigger deployment workflow:**
   - Go to: `https://github.com/OpenResilienceInitiative/.github`
   - Click **Actions** → **Deploy Workflows to All Repositories**
   - Click **Run workflow** → **Run workflow**

2. **Monitor workflow execution:**
   - Check workflow logs for each repository
   - Should see: "Processing: OpenResilienceInitiative/{repo}"
   - Should see: "✅ Successfully deployed workflows"

3. **Verify in target repositories:**
   ```bash
   # Check one of the ORISO repositories
   gh repo view OpenResilienceInitiative/ORISO-Frontend
   
   # Verify files exist
   # - .github/workflows/pr-validation.yml
   # - .github/pr-labeler.yml
   # - .github/size-labeler.yml
   ```

4. **Check created PRs:**
   - Each repository should have a PR titled "chore: Add PR validation workflow and config files"
   - Review and merge PRs to activate workflows

**Expected Output:**
```
🚀 Deploying workflows and config files to all ORISO repositories...
✅ Can access organization: OpenResilienceInitiative
✅ ORISO-Frontend: Successfully deployed workflows
✅ ORISO-UserService: Successfully deployed workflows
...
✅ Successfully processed: 17/17 repositories
```

**Troubleshooting:**

| Issue | Solution |
|-------|----------|
| "Repository not found" | Check PAT has `repo` scope and access to org |
| "Authentication failed" | Verify `ORG_GITHUB_TOKEN` secret is set |
| "Cannot access organization" | PAT needs `read:org` scope |

### Test 3: Create Labels Workflow

**What it tests:** Label creation across all repositories

**Steps:**

1. **Trigger label creation:**
   - Go to: `https://github.com/OpenResilienceInitiative/.github`
   - Click **Actions** → **Create Labels Across Repositories**
   - Click **Run workflow** → **Run workflow**

2. **Verify labels created:**
   - Go to any ORISO repository → **Settings** → **Labels**
   - Should see 22 labels:
     - **Work Type:** `story`, `task`, `bug`, `hotfix`
     - **Priority:** `P0-Critical`, `P1-High`, `P2-Medium`, `P3-Low`
     - **Area:** `frontend`, `backend`, `api`, `database`, `infra`, `docs`
     - **Size:** `S`, `M`, `L`, `XL`
     - **State:** `needs-refinement`, `blocked`, `ready-to-merge`, `breaking-change`

3. **Test auto-labeling:**
   - Create a PR from `feature/new-login` branch
   - Should automatically get `story` label
   - Should get size label based on changes

**Expected Output:**
```
🏷️ Creating labels across all ORISO repositories...
✅ ORISO-Frontend: Created 22 labels
✅ ORISO-UserService: Created 22 labels
...
✅ Successfully created labels in 17/17 repositories
```

---

## 2️⃣ Testing GitHub Setup

### Test 1: Authentication & Access

**What it tests:** PAT authentication and organization access

**Steps:**

1. **Verify PAT is configured:**
   ```bash
   # In GitHub Actions or locally
   if [ -n "$ORG_GITHUB_TOKEN" ]; then
     echo "✅ PAT configured"
   else
     echo "❌ PAT not configured"
   fi
   ```

2. **Test organization access:**
   ```bash
   gh auth status
   gh api orgs/OpenResilienceInitiative
   ```

3. **Test repository access:**
   ```bash
   # Test accessing a private repository
   gh repo view OpenResilienceInitiative/ORISO-UserService
   ```

**Expected Output:**
```
✅ Authenticated as: your-username
✅ Can access organization: OpenResilienceInitiative
✅ Repository: ORISO-UserService (private)
```

### Test 2: Reusable Workflows

**What it tests:** Reusable workflow is accessible and working

**Steps:**

1. **Verify reusable workflow exists:**
   - Check: `.github/.github/workflows/pr-validation.yml`
   - Should have `workflow_call:` trigger

2. **Check caller workflow:**
   - In any ORISO repository: `.github/workflows/pr-validation.yml`
   - Should call: `OpenResilienceInitiative/.github/.github/workflows/pr-validation.yml@main`

3. **Test workflow call:**
   - Create a PR in any repository with the caller workflow
   - Workflow should execute and call the reusable workflow
   - Check Actions tab for workflow run

**Expected Output:**
```
Workflow: PR Validation & Quality Checks
Status: ✅ Completed
Jobs: validate-and-label (reusable workflow)
```

### Test 3: Configuration Files

**What it tests:** Config files are deployed and valid

**Steps:**

1. **Check config files exist:**
   ```bash
   # In any ORISO repository
   ls -la .github/
   # Should see:
   # - pr-labeler.yml
   # - size-labeler.yml
   ```

2. **Validate YAML syntax:**
   ```bash
   # Test YAML is valid
   yamllint .github/pr-labeler.yml
   yamllint .github/size-labeler.yml
   ```

3. **Test labeler config:**
   - Create PR from `feature/test-labeling`
   - Should get `story` label (based on branch name)
   - Should get size label based on file changes

**Expected Files:**
```
.github/
├── workflows/
│   └── pr-validation.yml (calls reusable workflow)
├── pr-labeler.yml (branch-based labeling)
└── size-labeler.yml (size classification)
```

---

## 3️⃣ Testing CodeRabbit Integration

### Prerequisites

✅ **CodeRabbit Setup Required:**
1. Install CodeRabbit GitHub App: https://github.com/apps/coderabbitai
2. Grant access to `OpenResilienceInitiative` organization
3. Configure in repository settings (if needed)

### Test 1: CodeRabbit GitHub App Installation

**What it tests:** CodeRabbit is installed and accessible

**Steps:**

1. **Verify installation:**
   - Go to: `https://github.com/organizations/OpenResilienceInitiative/settings/installations`
   - Should see "CodeRabbit" or "codeRabbitAI" in installed apps
   - Status should be "Active"

2. **Check repository access:**
   - Click on CodeRabbit app
   - Verify it has access to required repositories
   - Should have "Read and write" permissions

**Expected Status:**
```
App: CodeRabbit
Status: ✅ Active
Access: OpenResilienceInitiative organization
Permissions: Read and write
```

### Test 2: CodeRabbit Automated Reviews

**What it tests:** CodeRabbit reviews PRs automatically

**Steps:**

1. **Create a test PR with code changes:**
   ```bash
   # Create a test branch
   git checkout -b test/coderabbit-review
   
   # Make some code changes (introduce a potential issue)
   # Example: Add a function with no error handling
   echo "function test() { return data; }" >> test.js
   
   git add test.js
   git commit -m "test: add test function"
   git push origin test/coderabbit-review
   ```

2. **Create PR:**
   - Title: `test: add test function for CodeRabbit review`
   - Body: Describe what the PR does
   - Base branch: `main`

3. **Wait for CodeRabbit review:**
   - Usually takes 1-3 minutes
   - CodeRabbit bot should comment on the PR
   - Should provide code review suggestions

4. **Verify review includes:**
   - ✅ Code quality suggestions
   - ✅ Security recommendations (if applicable)
   - ✅ Best practices feedback
   - ✅ Performance suggestions

**Expected Output:**
```
🤖 CodeRabbit has reviewed your PR:

## 📋 Summary
- Found 2 issues that need attention
- 1 suggestion for improvement

## 🔍 Issues Found
1. Missing error handling in function
2. Potential security concern with direct data access

## 💡 Suggestions
- Add try-catch block for error handling
- Validate input data before processing
```

### Test 3: CodeRabbit Configuration

**What it tests:** CodeRabbit settings are correct

**Steps:**

1. **Check repository settings:**
   - Go to repository → **Settings** → **CodeRabbit** (if available)
   - Or check `.github` repository for CodeRabbit config files

2. **Verify configuration file (if exists):**
   ```bash
   # Check for CodeRabbit config
   find .github -name "*coderabbit*" -o -name "*code-rabbit*"
   # Or check .github/coderabbit.yml or similar
   ```

3. **Test with different PR types:**
   - Small PR (1-5 files) - Should get quick review
   - Large PR (20+ files) - Should get comprehensive review
   - Security-related changes - Should flag security issues

**Configuration Options (if available):**
```yaml
# .github/coderabbit.yml (example)
reviews:
  enabled: true
  high_priority: true
  language:
    - javascript
    - typescript
    - java
  exclude_paths:
    - "**/*.lock"
    - "**/node_modules/**"
```

---

## 🧪 Comprehensive Test Suite

### End-to-End Test Scenario

**Scenario:** Complete PR workflow from creation to merge

**Steps:**

1. **Setup:**
   ```bash
   # Create test branch
   git checkout -b feat/test-complete-workflow
   
   # Make meaningful changes
   # - Add feature code
   # - Update tests
   # - Update documentation
   ```

2. **Create PR:**
   - Title: `feat: implement user profile feature`
   - Body: Complete PR template with all sections filled
   - Include screenshots (if UI changes)
   - Link to related issues

3. **Verify automated checks:**
   - ✅ PR Validation workflow runs
   - ✅ Semantic title check passes
   - ✅ PR body validation passes
   - ✅ Auto-labeling applies: `feat`, `story`, size label
   - ✅ Security scan completes
   - ✅ Code quality checks pass

4. **Verify CodeRabbit review:**
   - ✅ CodeRabbit comments appear
   - ✅ Suggestions are relevant and actionable
   - ✅ Review covers code quality, security, best practices

5. **Address feedback:**
   - ✅ Fix issues identified by CodeRabbit
   - ✅ Address human reviewer comments
   - ✅ Update PR if needed

6. **Final checks:**
   - ✅ All CI checks pass
   - ✅ Required approvals obtained
   - ✅ No blocking issues
   - ✅ Ready to merge

**Success Criteria:**
- All automated checks pass
- CodeRabbit review completed
- Human reviewers approve
- PR can be merged

---

## 🔍 Troubleshooting Guide

### Workflow Issues

| Issue | Solution |
|-------|----------|
| Workflow not running | Check Actions are enabled in repo settings |
| "Repository not found" | Verify PAT has correct scopes (`repo`, `read:org`) |
| "Authentication failed" | Check `ORG_GITHUB_TOKEN` secret is set correctly |
| Workflow fails on validation | Check PR title format and body completeness |
| Labels not applied | Verify labeler config files exist and YAML is valid |

### GitHub Setup Issues

| Issue | Solution |
|-------|----------|
| Can't access org repos | PAT needs `read:org` scope |
| Reusable workflow not found | Check workflow path and branch reference |
| Config files missing | Re-run deploy workflow |
| Labels missing | Run create-labels workflow |

### CodeRabbit Issues

| Issue | Solution |
|-------|----------|
| CodeRabbit not reviewing | Check app is installed and active |
| Reviews delayed | Large PRs may take longer (5-10 min) |
| No reviews appearing | Verify app has access to repository |
| Reviews seem incorrect | Check CodeRabbit configuration settings |

---

## 📊 Test Checklist

Use this checklist to verify your complete setup:

### Workflows ✅
- [ ] PR validation workflow runs on PR creation
- [ ] Semantic title validation works
- [ ] PR body validation works
- [ ] Auto-labeling applies correct labels
- [ ] Security scan (Trivy) completes
- [ ] Code quality checks run
- [ ] Deploy workflow creates PRs in all repos
- [ ] Create labels workflow creates all 22 labels

### GitHub Setup ✅
- [ ] PAT (`ORG_GITHUB_TOKEN`) is configured
- [ ] Can access organization repositories
- [ ] Reusable workflow is accessible
- [ ] Caller workflows exist in target repos
- [ ] Config files (pr-labeler.yml, size-labeler.yml) exist
- [ ] YAML files are valid

### CodeRabbit ✅
- [ ] CodeRabbit app is installed
- [ ] App has access to organization
- [ ] Reviews appear on PRs
- [ ] Reviews are relevant and helpful
- [ ] Configuration is correct (if applicable)

---

## 📚 Related Documentation

- **[Setup Workflow Deployment](./SETUP_WORKFLOW_DEPLOYMENT.md)** - PAT setup guide
- **[Workflow Deployment Guide](./WORKFLOW_DEPLOYMENT_GUIDE.md)** - Deployment details
- **[Code Review Guide](./CODE_REVIEW_GUIDE.md)** - CodeRabbit and review standards
- **[PR Template Guide](./PR_TEMPLATE_SETUP_GUIDE.md)** - PR template usage
- **[Label Setup Guide](./LABEL_SETUP_GUIDE.md)** - Label system details

---

## 🚀 Quick Test Commands

### Test Workflow Locally (with act)

```bash
# Install act (GitHub Actions locally)
# https://github.com/nektos/act

# Test PR validation workflow
act pull_request -e test-pr-event.json

# Test deployment workflow
act workflow_dispatch -W .github/workflows/deploy-workflows.yml
```

### Test Authentication

```bash
# Test PAT
gh auth status

# Test org access
gh api orgs/OpenResilienceInitiative

# Test repo access
gh repo view OpenResilienceInitiative/ORISO-Frontend
```

### Test Labeler Config

```bash
# Validate YAML syntax
yamllint .github/pr-labeler.yml
yamllint .github/size-labeler.yml

# Test labeler locally (if tool available)
labeler --config .github/pr-labeler.yml --test
```

---

*Last Updated: January 2025*


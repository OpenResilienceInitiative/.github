# 🔄 Template Sync Guide

**Sync PR and Issue templates from `.github` repository to other repositories.**

---

## 🚀 Quick Start

Add this workflow to your repository:

```yaml
# .github/workflows/template-sync.yml
name: Sync PR and Issue Templates

on:
  workflow_dispatch:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday

jobs:
  sync-templates:
    uses: OpenResilienceInitiative/.github/.github/workflows/template-sync.yml@main
```

**That's it!** Run it manually from Actions or it runs weekly automatically.

---

## 📖 What It Does

1. ✅ Fetches PR and Issue templates from `.github` repository
2. ✅ Creates a branch with template updates
3. ✅ Opens a PR for review
4. ✅ Only syncs templates (no other files)

**Synced paths:**
- `.github/PULL_REQUEST_TEMPLATE/`
- `.github/ISSUE_TEMPLATE/`
- `PULL_REQUEST_TEMPLATE.md`

---

## 🎯 How to Use

### Manual Sync

1. Go to **Actions** → **Sync PR and Issue Templates**
2. Click **Run workflow** → **Run workflow**
3. Review and merge the created PR

### Automatic Sync

The workflow runs weekly on Monday at 2 AM UTC. You'll get a PR if templates have changed.

---

## 🔧 Troubleshooting

**"Repository not found"**
- Ensure the workflow has access (for private repos, use `ORG_GITHUB_TOKEN` secret)

**"No changes detected"**
- Templates are already up to date with the template repository

**"Workflow fails"**
- Check repository permissions (needs `contents: write` and `pull-requests: write`)

---

## 📚 Related Docs

- **[README.md](./README.md)** - Organization overview
- **[Workflow Deployment Guide](./WORKFLOW_DEPLOYMENT_GUIDE.md)** - Deploy workflows

---

*Last Updated: January 2025*

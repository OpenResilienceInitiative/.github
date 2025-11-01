# Label Setup Guide for GitHub Projects

> **📚 Organization README:** For a complete overview of contributing to ORISO Platform, see [README.md](./README.md)

This guide explains the improved label system that aligns with your GitHub Projects structure (Epic, Story, Task, Bug) while providing granular filtering capabilities.

## 📋 Label Categories

### 1. Work Type Labels (for GitHub Projects Custom Field mapping)

These labels map to your GitHub Projects **Custom Field: Type** (Epic, Story, Task, Bug):

| Label | Branch Patterns | Usage |
|-------|----------------|-------|
| `story` | `feature/*`, `feat/*`, `story/*` | User-facing features or large pieces of work |
| `task` | `task/*`, `chore/*`, `refactor/*`, `devops/*`, `infra/*`, `docs/*` | Technical work, setup, or items too small to be a story |
| `bug` | `fix/*`, `bugfix/*`, `bug/*` | Issues or defects reported in the code |
| `hotfix` | `hotfix/*` | Urgent production fixes |

**Note:** Epic labels should be manually added when creating epics in GitHub Projects.

### 2. Priority Labels

| Label | Color Suggestion | Auto-detection Keywords |
|-------|------------------|------------------------|
| `P0-Critical` | 🔴 Red (#d73a4a) | critical, urgent, p0, hotfix, production down, security, data loss |
| `P1-High` | 🟠 Orange (#fb8500) | high priority, p1, important, blocker, major |
| `P2-Medium` | 🟡 Yellow (#ffb703) | medium, p2 |
| `P3-Low` | 🟢 Green (#06d6a0) | low, p3, nice to have |

### 3. Area/Component Labels

These labels help filter and categorize work by system area:

| Label | Auto-detection | Branch Patterns |
|-------|---------------|-----------------|
| `frontend` | `.tsx`, `.ts`, `.jsx`, `.js`, `.css`, `.scss`, `.vue` files | `frontend/*` |
| `backend` | `.java`, `.py`, `.go`, `.rs`, `pom.xml`, `requirements.txt` | `backend/*`, `api/*` |
| `api` | `/api/`, `/routes/`, `/controllers/` paths | `api/*` |
| `database` | `.sql`, `/migrations/`, `/schema/` paths | - |
| `infra` | `.github/`, `Dockerfile`, `.yml`, `.yaml`, `/kubernetes/`, `/terraform/` | `infra/*`, `devops/*` |
| `docs` | `.md`, `/docs/`, `/documentation/` paths | `docs/*` |

### 4. State Labels

| Label | Color Suggestion | Auto-detection |
|-------|------------------|----------------|
| `needs-refinement` | ⚪ Gray (#6a737d) | "wip", "draft", "[wip]", "[draft]" in title |
| `blocked` | 🔴 Red | Manual assignment |
| `ready-to-merge` | 🟢 Green | Manual assignment |

### 5. Size Labels

Auto-assigned based on number of files changed:

| Label | File Count | Color Suggestion |
|-------|-----------|------------------|
| `S` | 1-9 files | 🟢 Green |
| `M` | 10-29 files | 🟡 Yellow |
| `L` | 30-99 files | 🟠 Orange |
| `XL` | 100+ files | 🔴 Red |

### 6. Special Labels

| Label | Auto-detection | Usage |
|-------|---------------|-------|
| `breaking-change` | "breaking", "breaking change", "!:", "major", "⚠️" | Indicates breaking changes |

## 🎨 Setting Up Labels in GitHub

1. Go to your repository → **Settings** → **Labels**
2. For each label above, click **New label** and configure:
   - **Label name**: Use exact names above (e.g., `story`, `P0-Critical`)
   - **Color**: Use suggested colors or your team's color scheme
   - **Description**: Add brief description for team reference

### Quick Setup Script

You can use GitHub CLI to create labels programmatically:

```bash
# Work Type Labels
gh label create "story" --description "User-facing feature" --color "0E8A16"
gh label create "task" --description "Technical work" --color "0052CC"
gh label create "bug" --description "Defect fix" --color "D73A4A"
gh label create "hotfix" --description "Urgent production fix" --color "B60205"

# Priority Labels
gh label create "P0-Critical" --description "Critical priority" --color "D73A4A"
gh label create "P1-High" --description "High priority" --color "FB8500"
gh label create "P2-Medium" --description "Medium priority" --color "FFB703"
gh label create "P3-Low" --description "Low priority" --color "06D6A0"

# Area Labels
gh label create "frontend" --description "Frontend changes" --color "E99695"
gh label create "backend" --description "Backend changes" --color "7057FF"
gh label create "api" --description "API changes" --color "008672"
gh label create "database" --description "Database changes" --color "FBCA04"
gh label create "infra" --description "Infrastructure changes" --color "F9D0C4"
gh label create "docs" --description "Documentation" --color "D4C5F9"

# State Labels
gh label create "needs-refinement" --description "Needs more work" --color "6A737D"
gh label create "blocked" --description "Blocked by external dependency" --color "D73A4A"
gh label create "ready-to-merge" --description "Ready for merge" --color "0E8A16"

# Size Labels
gh label create "S" --description "Small: 1-9 files" --color "0E8A16"
gh label create "M" --description "Medium: 10-29 files" --color "FFB703"
gh label create "L" --description "Large: 30-99 files" --color "FB8500"
gh label create "XL" --description "Extra Large: 100+ files" --color "D73A4A"

# Special Labels
gh label create "breaking-change" --description "Contains breaking changes" --color "B60205"
```

## 🔄 How Auto-Labeling Works

The PR validation workflow automatically applies labels based on:

1. **Branch Name** → Work Type & Area labels (via `pr-labeler.yml`)
2. **File Changes** → Area labels (detected from file extensions/paths)
3. **PR Title/Body** → Priority labels (keyword detection)
4. **File Count** → Size labels (S/M/L/XL)
5. **Keywords** → Breaking change, state labels

## 📊 Using Labels in GitHub Projects

In your GitHub Project:

1. **Filter by Work Type**: Show all Stories, Tasks, or Bugs
2. **Filter by Priority**: Show all P0-Critical items
3. **Filter by Area**: Show all frontend or backend work
4. **Combine Filters**: Show all "frontend" + "story" + "P1-High" items
5. **Group by Labels**: Organize your board columns by label categories

## ✅ Benefits of This System

- ✅ **Flexible**: Multiple labels per PR allow rich filtering
- ✅ **Automatic**: Most labels applied automatically based on branch/content
- ✅ **Aligned**: Works with GitHub Projects Custom Fields (Type)
- ✅ **Granular**: Filter by any combination of labels
- ✅ **Visual**: Color-coded for quick identification
- ✅ **Simple**: Easy to understand and maintain


# Centralized PR Templates Setup ✅

## 📍 Current Location

PR templates are now **centralized** in the `.github` repository at the **root level**:

```
.github/
├── pull_request_template/          ← Templates directory (CORRECT location)
│   ├── architecture.md
│   ├── backend.md
│   ├── bugfix.md
│   ├── default.md
│   ├── devops.md
│   ├── docs.md
│   ├── frontend.md
│   └── hotfix.md
└── ...
```

## ⚠️ Important Requirements

For organization-wide PR templates to work, follow GitHub's exact specifications:

1. **Repository Name**: Must be exactly `.github` (not `.github-repo` or any variant) ✅

2. **Repository Visibility**: The `.github` repository **must be public** (or accessible to all target repositories) for templates to be accessible organization-wide.

3. **Correct Location**: Templates **must** be at:
   - `pull_request_template/` (lowercase, with underscore) ✅ **CURRENT - CORRECT**
   - Located at the **root** of the `.github` repository ✅
   - NOT nested in `.github/.github/` ❌

4. **File Format**: 
   - All templates must be `.md` (Markdown) files ✅
   - Case-sensitive naming (lowercase directory, lowercase files)

5. **Auto-Availability**: Once pushed to the `.github` repository, templates automatically appear in all organization repositories that don't have their own templates.

## ✅ How It Works

When creating a PR in **any repository** in your organization:
1. Click "Add a description" 
2. GitHub shows: **"Choose a template"** dropdown
3. Select from 8 available templates:
   - `default.md` - Generic template
   - `frontend.md` - UI/React components
   - `backend.md` - APIs/services
   - `docs.md` - Documentation
   - `bugfix.md` - Bug fixes
   - `devops.md` - Infrastructure
   - `architecture.md` - Major refactors
   - `hotfix.md` - Urgent fixes

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
.github/pull_request_template/  ✅ Root level, lowercase, underscores

# Wrong locations:
.github/.github/pull_request_template/  ❌ Nested (wrong)
PULL_REQUEST_TEMPLATE/                  ❌ Wrong case
pull-request-template/                  ❌ Wrong separator
```

**Check 4: File Names**
- ✅ All templates are `.md` files
- ✅ Directory name: `pull_request_template` (lowercase, underscore)
- ✅ Files are lowercase: `frontend.md`, `backend.md`, etc.

**Check 5: Single Template File Conflict** ⚠️ **CRITICAL**
- **DO NOT** have `pull_request_template.md` at the root of `.github` repository
- A single file at root **overrides** the directory-based templates and prevents the dropdown
- You must have **ONLY** the `pull_request_template/` directory (not both)
- Delete any `pull_request_template.md` file at the root level

**Check 6: Repository Override**
- If a repository has its own `pull_request_template/` directory OR `PULL_REQUEST_TEMPLATE.md` file, it **overrides** organization templates for that specific repository only
- Organization templates apply to all repos **without** local templates

**Check 7: Refresh After Changes**
- After pushing template updates, you may need to refresh or create a new PR draft to see the updated templates

## 📝 Next Steps

1. **Verify Repository is Public**:
   - Go to: https://github.com/OpenResilienceInitiative/.github/settings
   - Ensure it's set to **Public**

2. **Commit and Push**:
   ```bash
   git add pull_request_template/
   git commit -m "feat: centralize PR templates at repository root"
   git push
   ```

3. **Test in Any Repository**:
   - Go to any ORISO repository
   - Create a new PR
   - Click "Add a description"
   - You should see "Choose a template" dropdown

## 📚 References

- [GitHub: Creating a Pull Request Template](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
- [Organization-Wide Templates](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)

---

*Last Updated: November 2025*


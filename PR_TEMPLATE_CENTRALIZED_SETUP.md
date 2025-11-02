# Centralized PR Templates Setup ✅

## 📍 Current Location

PR templates are now **centralized** in the `.github` repository at the **root level**:

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
└── ...
```

## ⚠️ Important Requirements

For organization-wide PR templates to work, follow GitHub's exact specifications:

1. **Repository Name**: Must be exactly `.github` (not `.github-repo` or any variant) ✅

2. **Repository Visibility**: The `.github` repository **must be public** (or accessible to all target repositories) for templates to be accessible organization-wide.

3. **Correct Location**: Templates **must** be at:
   - `PULL_REQUEST_TEMPLATE/` (uppercase, with underscore) ✅ **CURRENT - CORRECT**
   - Located at the **root** of the `.github` repository ✅
   - NOT nested in `.github/.github/` ❌
   - Per GitHub docs: `.github/PULL_REQUEST_TEMPLATE/` for multiple templates

4. **File Format**: 
   - All templates must be `.md` (Markdown) files ✅
   - Case-sensitive naming (lowercase directory, lowercase files)

5. **Auto-Availability**: Once pushed to the `.github` repository, templates automatically appear in all organization repositories that don't have their own templates.

## ✅ How It Works

**Important Note:** Unlike Issue templates, GitHub does **not** provide an automatic template chooser UI for Pull Requests. You need to use query parameters to select templates.

### Option 1: Use Query Parameters (Manual Selection)

When creating a PR, add the template name to the URL:

```
https://github.com/OpenResilienceInitiative/REPO-NAME/compare/main...branch?expand=1&template=template-name.md
```

**Available Templates:**
- `default.md` - Generic template
- `frontend.md` - UI/React components
- `backend.md` - APIs/services
- `docs.md` - Documentation
- `bugfix.md` - Bug fixes
- `devops.md` - Infrastructure
- `architecture.md` - Major refactors
- `hotfix.md` - Urgent fixes

### Option 2: Auto-Populated Default Template (Current Setup)

We have **both**:
- ✅ `PULL_REQUEST_TEMPLATE.md` at root - Auto-populates as default template
- ✅ `PULL_REQUEST_TEMPLATE/` directory - Contains 8 specialized templates

**How it works:**
1. When creating a PR, the default template (`PULL_REQUEST_TEMPLATE.md`) auto-populates
2. The default template includes links to other templates
3. Users can manually change the URL to select a different template using query parameters

### Option 3: Create PR Links with Templates Pre-Selected

You can bookmark or share links with templates pre-selected:

- **Frontend PRs:** `?expand=1&template=frontend.md`
- **Backend PRs:** `?expand=1&template=backend.md`
- **Docs PRs:** `?expand=1&template=docs.md`
- **Bug Fixes:** `?expand=1&template=bugfix.md`

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
- **DO NOT** have `PULL_REQUEST_TEMPLATE.md` or `pull_request_template.md` at the root of `.github` repository
- A single file at root **overrides** the directory-based templates and disables template selection
- You must have **ONLY** the `PULL_REQUEST_TEMPLATE/` directory (not both)
- Delete any `PULL_REQUEST_TEMPLATE.md` or `pull_request_template.md` file at the root level
- **Trade-off:** Single file = auto-populates but only 1 template | Directory = 8 templates but requires query parameters

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
   - Create a new PR with template: `?expand=1&template=default.md`
   - The template should auto-populate in the description field
   - **Note:** GitHub doesn't show a dropdown - you must use the URL parameter

## 📚 References

- [GitHub: Creating a Pull Request Template](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
- [Organization-Wide Templates](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)

---

*Last Updated: November 2025*


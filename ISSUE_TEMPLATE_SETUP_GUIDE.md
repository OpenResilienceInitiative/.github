# Centralized Issue Templates Setup ✅

## 📍 Current Location

Issue templates are now **centralized** in the `.github` repository at the **root level**:

```
.github/
├── ISSUE_TEMPLATE/              ← Templates directory (CORRECT location)
│   ├── config.yml               ← Template chooser configuration
│   ├── 1-bug-report.yml         ← Bug report template
│   ├── 2-feature-request.yml    ← Feature request template
│   ├── 3-documentation.yml      ← Documentation template
│   └── 4-question-support.yml   ← Question/Support template
└── ...
```

## ⚠️ Important Requirements

For organization-wide issue templates to work, follow GitHub's exact specifications:

1. **Repository Name**: Must be exactly `.github` (not `.github-repo` or any variant) ✅

2. **Repository Visibility**: The `.github` repository **must be public** (or accessible to all target repositories) for templates to be accessible organization-wide.

3. **Correct Location**: Templates **must** be at:
   - `ISSUE_TEMPLATE/` (uppercase, with underscore) ✅ **CURRENT - CORRECT**
   - Located at the **root** of the `.github` repository ✅
   - NOT nested in `.github/.github/` ❌
   - Per GitHub docs: `.github/ISSUE_TEMPLATE/` for multiple templates

4. **File Format**: 
   - Templates use YAML format (`.yml`) for issue forms ✅
   - `config.yml` configures the template chooser ✅

5. **Auto-Availability**: Once pushed to the `.github` repository, templates automatically appear in all organization repositories that don't have their own templates.

## ✅ How It Works

### Issue Template Chooser

When someone creates a new issue in any repository without its own issue templates, they will see:

1. **Template Selection Screen**: A chooser with all available templates
2. **Contact Links**: Links to documentation, discussions, and security reporting
3. **Blank Issues**: Disabled by default (can be enabled in `config.yml`)

### Available Templates

| Template | Purpose | Auto-Labels |
|----------|---------|-------------|
| 🐛 Bug Report | Report bugs or unexpected behavior | `bug`, `triage` |
| ✨ Feature Request | Suggest new features or enhancements | `enhancement`, `triage` |
| 📚 Documentation | Request documentation improvements | `documentation`, `triage` |
| ❓ Question / Support | Ask questions or get help | `question`, `support` |

### Template Features

Each template includes:
- **Service/Component Selection**: Dropdowns to identify which ORISO service is affected
- **Priority Levels**: P0-Critical through P3-Low (matching your PR label system)
- **Structured Fields**: Required and optional fields to capture all necessary information
- **Validation**: Required fields ensure quality issue reports
- **Auto-Labeling**: Templates automatically apply relevant labels

## 🔧 Configuration

### `config.yml` Settings

```yaml
blank_issues_enabled: false  # Disable blank issues (forces template use)
contact_links:
  - Documentation link
  - Discussions link
  - Security advisories link
```

### Template Ordering

Templates appear in the chooser in alphanumeric order. The numeric prefix (`1-`, `2-`, etc.) controls the display order:
- `1-bug-report.yml` appears first
- `2-feature-request.yml` appears second
- And so on...

**Note**: If you have 10+ templates, use zero-padding (`01-`, `02-`, `11-`) to maintain proper ordering.

## 🔄 Repository Override

### How Overrides Work

- **Organization Templates**: Apply to all repos **without** local templates
- **Repository-Specific Templates**: If a repository has its own `ISSUE_TEMPLATE/` folder, it **overrides** organization templates for that specific repository only
- **Best Practice**: Only create repository-specific templates if a repo has unique requirements

### Checking for Overrides

To check if a repository has its own templates:

```bash
# Check if repo has local issue templates
ls -la REPO-NAME/.github/ISSUE_TEMPLATE/
```

If the directory exists, that repo uses its own templates instead of organization templates.

## 🧪 Testing

### Test in Any Repository

1. **Navigate to any ORISO repository** (that doesn't have its own templates)
2. **Click "New Issue"**
3. **You should see**:
   - Template chooser with 4 templates
   - Contact links sidebar
   - No "Blank issue" option (since `blank_issues_enabled: false`)

### Verify Template Functionality

1. Select a template (e.g., "Bug Report")
2. Fill out the form fields
3. Verify required field validation works
4. Submit the issue
5. Check that labels are automatically applied

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
.github/ISSUE_TEMPLATE/  ✅ Root level, UPPERCASE, underscores

# Wrong locations:
.github/.github/ISSUE_TEMPLATE/  ❌ Nested (wrong)
issue_template/                   ❌ Wrong case (lowercase)
issue-template/                   ❌ Wrong separator
```

**Check 4: File Format**
- ✅ All templates are `.yml` files (YAML format for issue forms)
- ✅ `config.yml` exists in the `ISSUE_TEMPLATE/` directory
- ✅ Directory name: `ISSUE_TEMPLATE` (UPPERCASE, underscore)

**Check 5: YAML Syntax**
- ✅ All YAML files must be valid
- ✅ Check for proper indentation (2 spaces)
- ✅ Verify all required fields have `validations.required: true`

**Check 6: Repository Override**
- If a repository has its own `ISSUE_TEMPLATE/` directory, it **overrides** organization templates for that specific repository only
- Organization templates apply to all repos **without** local templates

**Check 7: Refresh After Changes**
- After pushing template updates, you may need to refresh or create a new issue to see the updated templates
- Template changes are cached by GitHub

## 📝 Customizing Templates

### Adding New Templates

1. **Create new template file** in `.github/ISSUE_TEMPLATE/`:
   ```bash
   .github/ISSUE_TEMPLATE/5-your-template.yml
   ```

2. **Follow the YAML format** from existing templates

3. **Set numeric prefix** to control ordering (e.g., `5-`)

4. **Add to this guide** under "Available Templates"

### Modifying Existing Templates

1. Edit the template file (e.g., `1-bug-report.yml`)
2. Test locally using GitHub's template preview
3. Commit and push to `.github` repository
4. Changes propagate automatically to all repos

### Template Structure

Each template follows this structure:

```yaml
name: Template Name
description: Template description
title: "[Prefix]: "
labels: ["label1", "label2"]
type: bug|feature|documentation|question
body:
  - type: markdown|input|textarea|dropdown|checkboxes
    id: field-id
    attributes:
      label: Field Label
      description: Field description
      # ... field-specific attributes
    validations:
      required: true|false
```

## 📚 Template Details

### 🐛 Bug Report Template

**Fields:**
- Affected Service/Component (dropdown, required)
- Priority (dropdown, required)
- Bug Description (textarea, required)
- Steps to Reproduce (textarea, required)
- Expected Behavior (textarea, required)
- Actual Behavior (textarea, required)
- Environment (textarea, optional)
- Relevant Logs/Error Messages (textarea, optional)
- Screenshots/Videos (textarea, optional)
- Workaround (textarea, optional)

**Auto-Labels:** `bug`, `triage`

### ✨ Feature Request Template

**Fields:**
- Target Service/Component (dropdown, required)
- Priority (dropdown, required)
- Problem Statement (textarea, required)
- Proposed Solution (textarea, required)
- Alternatives Considered (textarea, optional)
- Impact & Benefits (textarea, optional)
- Technical Considerations (textarea, optional)
- Related Documentation/Links (textarea, optional)

**Auto-Labels:** `enhancement`, `triage`

### 📚 Documentation Template

**Fields:**
- Documentation Type (dropdown, required)
- Documentation Location (dropdown, required)
- Issue Description (textarea, required)
- Affected Repository/File (textarea, optional)
- Proposed Content (textarea, optional)
- Additional Context (textarea, optional)

**Auto-Labels:** `documentation`, `triage`

### ❓ Question / Support Template

**Fields:**
- Question Type (dropdown, required)
- Related Service/Component (dropdown, optional)
- Your Question (textarea, required)
- Context (textarea, optional)
- Environment (textarea, optional)

**Auto-Labels:** `question`, `support`

## 📚 References

- [GitHub: Creating Issue Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-issue-templates-for-your-repository)
- [GitHub: Issue Form Schema](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
- [Organization-Wide Templates](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)

## 🚀 Next Steps

1. **Verify Repository is Public**:
   - Go to: https://github.com/OpenResilienceInitiative/.github/settings
   - Ensure it's set to **Public**

2. **Commit and Push**:
   ```bash
   git add ISSUE_TEMPLATE/
   git commit -m "feat: add centralized issue templates"
   git push
   ```

3. **Test in Any Repository**:
   - Go to any ORISO repository without local templates
   - Click "New Issue"
   - Verify templates appear in the chooser
   - Test creating an issue with a template

4. **Update Documentation**:
   - Add link to this guide in the main `.github/README.md`
   - Update any contribution guidelines

---

*Last Updated: January 2025*


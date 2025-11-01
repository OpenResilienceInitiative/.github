# Setup Workflow Deployment

> **Quick Fix:** If workflows fail to access private organization repositories, you need to set up a Personal Access Token (PAT).

## 🔑 Why Do I Need a PAT?

The default `GITHUB_TOKEN` provided by GitHub Actions has limited permissions:
- ✅ Can access the current repository (`.github`)
- ✅ Can read organization metadata
- ❌ **Cannot access other private repositories in the organization**

To deploy workflows to all 17 private ORISO repositories, you need a Personal Access Token with broader access.

> **Note**: You do **NOT** need SSH keys for this setup. PATs are different from SSH keys and are used for GitHub API and HTTPS authentication in workflows.

## 📝 Step-by-Step Setup

### ⚠️ Important: Which Account to Use?

**You must create the PAT using a personal GitHub account (not the organization account).**

**Requirements for the account:**
- ✅ Must be a **personal GitHub account** (not `@OpenResilienceInitiative`)
- ✅ Must be a **member** of the `OpenResilienceInitiative` organization
- ✅ Must have **access** to the private repositories (Member/Owner role)
- ✅ Recommended: Use an **organization Owner** or **Admin** account

**Why a personal account?**
- GitHub organization accounts cannot create Personal Access Tokens
- PATs are always created by individual user accounts
- The personal account's organization membership grants access to private repos

**Which account should you use?**
- ✅ Use the **same personal account** that created/owns the `.github` repository
- ✅ Or use any **organization member's account** with proper permissions
- ❌ Do NOT use the organization account (`OpenResilienceInitiative`)

### Step 1: Create a Personal Access Token (PAT)

**Important**: 
- Make sure you're logged into your **personal GitHub account** (not the organization)
- You do NOT need SSH keys for this - only a Personal Access Token

1. Go to GitHub Settings: https://github.com/settings/tokens
   - Make sure you're on your personal account settings page
   - The URL should be `github.com/settings/tokens` (not the org page)
   - **Note**: This is different from SSH keys - you're looking for "Personal access tokens" section
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Configure the token:
   - **Note**: `ORISO Workflow Deployment` (or any descriptive name)
   - **Expiration**: Choose an expiration period (recommend: 90 days or 1 year)
   - **Scopes**: Select these permissions:
     - ✅ `repo` (Full control of private repositories)
       - This includes all sub-scopes:
       - `repo:status`
       - `repo_deployment`
       - `public_repo`
       - `repo:invite`
       - `security_events`
4. Click **"Generate token"**
5. **Copy the token immediately** (you won't be able to see it again!)

### Step 2: Add Token as Repository Secret

1. Go to the `.github` repository: https://github.com/OpenResilienceInitiative/.github
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Configure the secret:
   - **Name**: `ORG_GITHUB_TOKEN`
   - **Secret**: Paste your PAT token
5. Click **"Add secret"**

### Step 3: Verify Setup

1. Go to the **Actions** tab
2. Find "Deploy Workflows to All Repositories"
3. Click **"Run workflow"** → **"Run workflow"**
4. Check the logs - you should see:
   ```
   ✅ Will use PAT (ORG_GITHUB_TOKEN) for authentication
   ✅ Can access organization: OpenResilienceInitiative
   ✅ Successfully cloned repositories
   ```

## ✅ After Setup

Once the PAT is configured:
- ✅ Workflows will automatically use `ORG_GITHUB_TOKEN` if available
- ✅ Falls back to `GITHUB_TOKEN` if PAT is not set
- ✅ Can access all 17 private ORISO repositories
- ✅ Can create pull requests in each repository

## 🔄 Updating the Token

When your PAT expires:
1. Generate a new PAT following Step 1
2. Go to repository secrets (Step 2)
3. Click on `ORG_GITHUB_TOKEN` secret
4. Click **"Update"**
5. Paste the new token
6. Save

## 🛡️ Security Best Practices

1. **Use Classic PAT with minimum required scopes** - Only `repo` scope is needed
2. **Set appropriate expiration** - Don't use "No expiration" unless necessary
3. **Rotate tokens periodically** - Generate new tokens every 90-180 days
4. **Don't commit tokens** - Always use repository secrets, never hardcode
5. **Review token usage** - Check token usage in GitHub settings periodically

## ❓ Troubleshooting

### "Repository not found or not accessible"

**Cause**: `GITHUB_TOKEN` doesn't have access to private org repos

**Solution**: Set up `ORG_GITHUB_TOKEN` secret as described above

### "Token expired"

**Cause**: PAT has expired

**Solution**: Generate a new PAT and update the secret

### "Insufficient permissions"

**Cause**: PAT doesn't have `repo` scope

**Solution**: Regenerate PAT with `repo` scope selected

### "Still can't access repositories"

**Possible causes**:
1. PAT was created with wrong account (used org account instead of personal)
2. Personal account is not a member of the organization
3. Personal account doesn't have access to private repos
4. Organization has SSO enabled (may need to authorize token)
5. Repository names in script don't match actual repos

**Solution**:
1. **Verify account**: Make sure PAT was created with a **personal account** that is a **member** of `OpenResilienceInitiative`
2. **Check organization membership**: Go to https://github.com/orgs/OpenResilienceInitiative/people and verify your account is listed
3. **Check repository access**: Verify the personal account can access at least one private repo manually
4. **Check PAT scopes**: Ensure PAT has `repo` scope
5. **SSO authorization**: If org has SSO, authorize the token: https://github.com/settings/tokens → Click token → "Enable SSO"
6. **Verify repository names**: Check `scripts/deploy-workflows.sh` matches actual repo names

## 📚 Related Documentation

- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Workflow Deployment Guide](./WORKFLOW_DEPLOYMENT_GUIDE.md)

---

*Last Updated: January 2025*


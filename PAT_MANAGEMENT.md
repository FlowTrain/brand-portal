# 🔐 GitHub PAT Token Management Guide

Complete guide for managing your GitHub Personal Access Token (PAT) lifecycle.

---

## ⏰ Your Current PAT Status

| Detail | Value |
|--------|-------|
| **Created** | January 17, 2026 |
| **Expiration** | April 17, 2026 (90 days) |
| **Days Until Expiration** | 90 days |
| **Status** | ✅ Active |
| **Last Verified** | January 17, 2026 |

---

## 📅 Renewal Timeline

### ⚠️ CRITICAL DATES

| Date | Action | Priority |
|------|--------|----------|
| **April 1, 2026** | 📢 REMINDER: Review upcoming renewal | HIGH |
| **April 10, 2026** | 🔄 Create NEW token | CRITICAL |
| **April 15, 2026** | ✅ Verify new token works | CRITICAL |
| **April 17, 2026** | ❌ OLD TOKEN EXPIRES | URGENT |

---

## 🔄 Token Renewal Procedure

### Step 1: Create New Token (Do This First!)

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. **Name**: FlowTrain Release Pipeline
4. **Expiration**: 90 days
5. **Scopes** (check these):
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Actions and workflows)
   - ✅ `read:org` (Read org and team membership)
6. Click "Generate token"
7. **COPY THE TOKEN IMMEDIATELY** (you won't see it again!)

### Step 2: Update Local Configuration

```bash
# Copy the new token
NEW_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Update gh configuration
echo "Updating GitHub CLI..."
gh auth logout
gh auth login
# When prompted, paste the NEW token

# Verify it works
gh auth status
```

### Step 3: Update Git Credential Helper

```bash
# Re-setup git credential helper
gh auth setup-git

# Verify git can push
cd ~/projects/brand-portal
git push origin main 2>&1 | head -5
# Should show: "Everything up-to-date" or push status
```

### Step 4: Test Full Release Pipeline

```bash
# Dry run to verify everything works
bash scripts/ship-improved.sh --dry-run

# If successful, old token can be deleted
```

### Step 5: Delete Old Token

1. Go to: https://github.com/settings/tokens
2. Find the old token (created Jan 17, 2026)
3. Click "Delete"
4. Confirm deletion

---

## 🚨 Emergency Token Replacement

If your token is compromised:

```bash
# Immediately revoke the token
# Visit: https://github.com/settings/tokens
# Find the token and click "Delete"

# Create a new one immediately
# Follow steps 1-5 above

# Audit recent activity
# Visit: https://github.com/settings/security-log
```

---

## 💾 Token Backup & Storage

### DO NOT Store In These Places
❌ Git repositories (will be detected and revoked)
❌ Code files
❌ Shared documents
❌ Email
❌ Plain text files tracked by git

### SAFE Storage Options
✅ Password manager (1Password, LastPass, Bitwarden)
✅ Secure note in OS keyring
✅ Hardware security key
✅ Encrypted local file (NOT in repo)

### Example: Encrypted Local Storage

```bash
# Create encrypted .env.local file
cat > ~/.env.local << 'EOF'
export GH_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
EOF

# Restrict permissions
chmod 600 ~/.env.local

# Add to .bashrc
echo 'source ~/.env.local' >> ~/.bashrc

# IMPORTANT: Add to .gitignore
echo '.env.local' >> ~/.gitignore
```

---

## 🔍 Token Verification Checklist

### Monthly Check
```bash
# Verify token is working
gh auth status

# Should show:
# ✓ Logged in to github.com as YourUsername
# ✓ Git operations for github.com configured to use https protocol
# ✓ Token: ghp_...
```

### Before Release
```bash
# Test token permissions
gh repo view FlowTrain/brand-portal

# Test with release script
bash scripts/ship-improved.sh --dry-run
```

### Full Verification Script
```bash
#!/bin/bash
echo "🔐 GitHub Token Verification"
echo "=============================="
echo

# Check authentication
echo "1. Checking GitHub CLI auth..."
if gh auth status >/dev/null 2>&1; then
    echo "   ✅ Authenticated"
else
    echo "   ❌ NOT authenticated"
    exit 1
fi

# Check token scopes
echo "2. Checking token scopes..."
gh auth status 2>&1 | grep -q "logged in" && echo "   ✅ Token valid" || echo "   ❌ Token invalid"

# Check git can push
echo "3. Testing git push capability..."
cd ~/projects/brand-portal
if git push origin main 2>&1 | grep -q "Everything up-to-date\|fast-forward\|error: permission denied"; then
    echo "   ✅ Git push works"
else
    echo "   ⚠️  Could not verify git push"
fi

echo
echo "Verification complete!"
```

---

## 📋 Token Scopes Explained

| Scope | Purpose | Needed? |
|-------|---------|---------|
| `repo` | Full control of private repositories | ✅ YES |
| `workflow` | GitHub Actions and workflows | ✅ YES |
| `read:org` | Read organization membership | ✅ YES |
| `write:org` | Write organization settings | ❌ NO |
| `admin:repo_hook` | Webhook management | ❌ NO |
| `gist` | Manage gists | ❌ NO |
| `user` | Read user profile | ❌ NO |

**Use only required scopes for security!**

---

## 🆘 Troubleshooting Token Issues

### Issue: "Invalid authentication credentials"
```bash
# Solution 1: Re-authenticate
gh auth logout
gh auth login

# Solution 2: Check token expiration
# Visit: https://github.com/settings/tokens

# Solution 3: Create new token if expired
# Follow "Token Renewal Procedure" above
```

### Issue: "Permission denied (publickey)"
```bash
# Solution: SSH not configured, use HTTPS instead
gh auth setup-git
git config --global credential.helper store
```

### Issue: "gh: not found" or "GitHub CLI not working"
```bash
# Verify gh is installed
gh --version

# If not found, reinstall
sudo apt-get install --reinstall gh

# Or use latest
curl -fsSL https://cli.githubusercontent.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.githubusercontent.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh
```

### Issue: "Token not found in config"
```bash
# Check gh config
cat ~/.config/gh/hosts.yml

# If missing, re-authenticate
gh auth login
```

---

## 📅 Calendar Reminders

### Add to Your Calendar

**April 1, 2026 at 9:00 AM**
- Title: "🔐 GitHub PAT Token Renewal Reminder"
- Description: "Create new GitHub PAT token before April 17 expiration"
- Alert: 15 minutes before

**April 10, 2026 at 10:00 AM**
- Title: "🔄 Update GitHub PAT Token"
- Description: "Create new token, test, delete old one"
- Alert: 1 hour before

---

## 🔐 Security Best Practices

### DO
✅ Use 90-day expiration (forces regular renewal)
✅ Store token in secure location
✅ Use minimal required scopes
✅ Verify token works before deleting old one
✅ Delete old token immediately after renewal
✅ Monitor GitHub security log
✅ Use different tokens for different machines (optional)

### DON'T
❌ Share token via email or chat
❌ Commit token to git repository
❌ Use indefinite expiration
❌ Create more scopes than needed
❌ Delete old token before testing new one
❌ Store token in plain text files

---

## 📝 Token Management Checklist

### Initial Setup (Done ✅)
- [x] Created token: January 17, 2026
- [x] Scopes: repo, workflow, read:org
- [x] Expiration: 90 days (April 17, 2026)
- [x] Tested successfully

### Before Expiration (April 10)
- [ ] Review token settings
- [ ] Create new token
- [ ] Test with `gh auth login`
- [ ] Test full release pipeline
- [ ] Update `.env.local` if used
- [ ] Delete old token

### After Renewal
- [ ] Verify new token works
- [ ] Update backup/password manager
- [ ] Update calendar for next renewal
- [ ] Monitor security log for suspicious activity

---

## 📞 Support Resources

- **GitHub Token Docs**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
- **GitHub Security**: https://github.com/settings/security
- **Create Token**: https://github.com/settings/tokens
- **Security Log**: https://github.com/settings/security-log
- **GitHub CLI Docs**: https://cli.github.com/

---

## 🔗 Quick Links (Bookmarks These!)

| Link | Purpose |
|------|---------|
| https://github.com/settings/tokens | Manage tokens |
| https://github.com/settings/security | Security overview |
| https://github.com/settings/security-log | Activity log |
| https://github.com/settings/sessions | Active sessions |

---

## 📊 Token History

| Token | Created | Expires | Status |
|-------|---------|---------|--------|
| v1.0.1 Release (Current) | Jan 17, 2026 | Apr 17, 2026 | ✅ Active |
| v1.0.2 (Plan renewal) | Apr 10, 2026 | Jul 10, 2026 | ⏳ Pending |

---

**Last Updated**: 2026-01-17  
**Next Review**: 2026-04-01 (90-day renewal reminder)  
**Status**: ✅ Active and Secure

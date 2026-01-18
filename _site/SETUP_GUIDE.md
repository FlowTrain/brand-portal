# 🖥️ FlowTrain Development Environment Setup Guide

Complete installation and setup instructions for Windows 11 + WSL Ubuntu 22.04.

---

## ⚠️ Important: PAT Token Reminder

**Your GitHub PAT expires in 90 days (April 17, 2026)**

### Renewal Checklist
- [ ] Mark calendar for early April 2026
- [ ] Create new PAT before expiration: https://github.com/settings/tokens
- [ ] Update `~/.config/gh/hosts.yml` with new token
- [ ] Test with: `gh auth status`
- [ ] Delete old token from GitHub settings

**How to update PAT:**
```bash
# Re-authenticate with new token
gh auth logout
gh auth login
# Paste new PAT when prompted
gh auth setup-git
```

---

## 🪟 Windows 11 Installation

### 1. Enable WSL
```powershell
# Run as Administrator
wsl --install
# Installs: WSL2 + Ubuntu 22.04 by default
```

### 2. Install Git CLI
```powershell
# Using winget (built into Windows 11)
winget install --id Git.Git

# Or download from https://git-scm.com/download/win
```

### 3. Install GitHub CLI
```powershell
winget install --id GitHub.CLI
```

### 4. Install 7-Zip
```powershell
winget install --id 7zip.7zip
```

### 5. Install Ruby (if needed for Windows development)
```powershell
# Using RubyInstaller
winget install --id RubyInstallerTeam.Ruby

# Or download from https://rubyinstaller.org/
```

### 6. Install VS Code (Optional but recommended)
```powershell
winget install --id Microsoft.VisualStudioCode
```

### 7. Verify Installations
```powershell
git --version
gh --version
7z
ruby --version  # if installed
```

---

## 🐧 WSL Ubuntu 22.04 Setup

### 1. Launch WSL Terminal
```powershell
wsl
```

### 2. Update System
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 3. Install Essential Tools
```bash
sudo apt-get install -y \
  build-essential \
  curl \
  wget \
  git \
  zsh \
  vim \
  nano \
  htop \
  zip \
  unzip \
  p7zip-full
```

### 4. Install Ruby 3.0+ (for Jekyll)
```bash
# Install Ruby with dependencies
sudo apt-get install -y \
  ruby-full \
  ruby-dev \
  bundler

# Verify installation
ruby --version
bundler --version
```

### 5. Install GitHub CLI
```bash
# Ubuntu repo has gh, but may be old
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.githubusercontent.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.githubusercontent.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# Verify
gh --version
```

### 6. Install Node.js (Optional, for frontend tools)
```bash
# Using NodeSource repository (for latest LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

### 7. Install Make
```bash
sudo apt-get install -y build-essential
make --version
```

### 8. Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
```

### 9. Authenticate GitHub
```bash
gh auth login
# Select: GitHub.com
# Select: HTTPS
# Paste your PAT token

# Setup git credential helper
gh auth setup-git

# Verify
gh auth status
```

### 10. Create Development Directory
```bash
mkdir -p ~/projects
mkdir -p ~/.config
```

---

## 📋 Installation Checklist

### Windows 11
- [ ] WSL2 enabled
- [ ] Git installed
- [ ] GitHub CLI installed
- [ ] 7-Zip installed
- [ ] Ruby installed (optional)
- [ ] VS Code installed (optional)

### WSL Ubuntu 22.04
- [ ] System updated
- [ ] Build tools installed
- [ ] Ruby 3.0+ installed
- [ ] GitHub CLI installed
- [ ] Node.js installed (optional)
- [ ] Make installed
- [ ] Git configured
- [ ] GitHub authenticated
- [ ] Development directories created

### GitHub Setup
- [ ] PAT token created (90-day expiration noted)
- [ ] gh authenticated
- [ ] Git credential helper configured

---

## 📦 Software Versions (Verified 2026-01-17)

| Software | Minimum | Tested | Windows | WSL |
|----------|---------|--------|---------|-----|
| Git | 2.30+ | 2.40+ | ✓ | ✓ |
| GitHub CLI | 2.0+ | 2.4.0 | ✓ | ✓ |
| Ruby | 2.7+ | 3.0.2 | ✓ | ✓ |
| Bundler | 2.0+ | 2.5.23 | ✓ | ✓ |
| Jekyll | 3.9.0 | 3.9.0 | | ✓ |
| 7-Zip | Latest | 16.x | ✓ | ✓ |
| Make | 4.0+ | 4.3+ | | ✓ |
| Node.js | 14+ | 18+ | | Optional |

---

## 🔧 Environment Setup

### WSL ~/.bashrc or ~/.zshrc
Add these for convenience:

```bash
# Aliases
alias ll='ls -lh'
alias la='ls -lah'
alias projects='cd ~/projects'

# GitHub repo shortcut
gh_clone() {
  gh repo clone "$1" ~/projects/$(basename "$1")
}

# Quick Docker check (if Docker installed)
alias docker='docker.exe'
alias docker-compose='docker-compose.exe'

# Ruby/Jekyll shortcuts
alias bundle-setup='bundle config set --local path ".bundle/gems"'
alias jekyll-serve='bundle exec jekyll serve'
```

### Windows PowerShell $PROFILE
```powershell
# Aliases
Set-Alias -Name ll -Value Get-ChildItem -Option AllScope -Force
Set-Alias -Name gh -Value "gh.exe" -Force

# Function to quickly access WSL
function wsl-home { wsl -e bash -c "cd ~; bash" }
function projects { cd $env:USERPROFILE\projects }
```

---

## 🚀 Quick Start After Setup

```bash
# 1. Clone FlowTrain repo
gh repo clone FlowTrain/brand-portal ~/projects/brand-portal

# 2. Enter project
cd ~/projects/brand-portal

# 3. Verify setup
make doctor

# 4. Install Jekyll gems
cd website/microsite
bundle config set --local path '.bundle/gems'
bundle install
cd ../..

# 5. Try first release (dry-run)
bash scripts/ship-improved.sh --dry-run
```

---

## 🔄 Update Schedule

### Monthly
- [ ] `sudo apt-get update && sudo apt-get upgrade -y` (WSL)
- [ ] Check GitHub CLI updates: `gh --version`
- [ ] Check Ruby updates: `ruby --version`

### Quarterly (April, July, October, January)
- [ ] Update GitHub PAT token (expires 90 days from creation)
- [ ] Review installed packages: `bundle outdated`

### Annually
- [ ] Full system backup
- [ ] Review WSL distribution version
- [ ] Check for major tool upgrades

---

## 🆘 Troubleshooting Initial Setup

### WSL Won't Start
```powershell
# Restart WSL
wsl --shutdown
wsl

# Or reset
wsl --unregister Ubuntu-22.04
wsl --install
```

### GitHub CLI Auth Fails
```bash
# Clear and re-authenticate
gh auth logout
rm -rf ~/.config/gh/
gh auth login
```

### Ruby Not Found in WSL
```bash
# Reinstall Ruby
sudo apt-get install --reinstall ruby-full bundler

# Or use rbenv for version management
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
eval "$(rbenv init -)"
rbenv install 3.0.2
```

### Git Credential Issues
```bash
# Reset git credential helper
git config --global --unset credential.helper
gh auth setup-git
```

---

## 📚 Helpful Resources

- **WSL Docs**: https://learn.microsoft.com/en-us/windows/wsl/
- **GitHub CLI**: https://cli.github.com/
- **Ruby**: https://www.ruby-lang.org/
- **Jekyll**: https://jekyllrb.com/
- **Git**: https://git-scm.com/

---

## ⏰ Important Dates

| Event | Date | Action |
|-------|------|--------|
| PAT Created | Jan 17, 2026 | Created 90-day token |
| PAT Expires | Apr 17, 2026 | ⚠️ **RENEW BEFORE THIS DATE** |
| GitHub CLI Check | Monthly | Keep up-to-date |
| System Update | Monthly | `sudo apt-get upgrade` |

---

## 📝 Setup Completion Checklist

- [ ] Windows 11 tools installed
- [ ] WSL2 + Ubuntu 22.04 running
- [ ] All required packages installed
- [ ] Git configured globally
- [ ] GitHub CLI authenticated
- [ ] PAT token verified (note 90-day expiration)
- [ ] Development directories created
- [ ] FlowTrain repo cloned
- [ ] Makefile working: `make doctor` passes
- [ ] First dry-run successful: `bash scripts/ship-improved.sh --dry-run`

---

**Status**: ✅ Ready for Development  
**Last Updated**: 2026-01-17  
**Next Review**: 2026-04-17 (PAT Renewal)

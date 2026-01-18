# 🖥️ Complete Device Setup & Dotfiles Plan

Guide for setting up a new Windows 11 machine from scratch with all FlowTrain development tools.

---

## 📋 Quick Reference

| Document | Purpose | Read When |
|----------|---------|-----------|
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | Installation & setup | Setting up new machine |
| **[DOTFILES_GUIDE.md](DOTFILES_GUIDE.md)** | Config management | Creating dotfiles repo |
| **[PAT_MANAGEMENT.md](PAT_MANAGEMENT.md)** | Token renewal | Before April 2026 |
| **[RELEASE_GUIDE.md](RELEASE_GUIDE.md)** | Release workflow | When releasing |
| **[RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md)** | Quick commands | Regular use |

---

## 🚀 New Device Setup (Fast Track)

### Time Required: ~30 minutes

**For Windows 11 + WSL Ubuntu 22.04:**

```powershell
# 1. WINDOWS SETUP (10 minutes)
# Run PowerShell as Administrator

# Install WSL
wsl --install
# Restart computer when complete

# Install required tools
winget install Git.Git
winget install GitHub.CLI
winget install 7zip.7zip

# Verify
git --version
gh --version
7z
```

```bash
# 2. WSL SETUP (15 minutes)
# Open WSL terminal

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install all tools
sudo apt-get install -y \
  build-essential curl wget git zsh vim nano htop \
  zip unzip p7zip-full make ruby-full ruby-dev bundler

# Install GitHub CLI
curl -fsSL https://cli.githubusercontent.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.githubusercontent.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install -y gh

# Authenticate GitHub
gh auth login
# Paste your PAT token when prompted
gh auth setup-git

# Create project directory
mkdir -p ~/projects

# Clone FlowTrain repo
gh repo clone FlowTrain/brand-portal ~/projects/brand-portal

# Test setup
cd ~/projects/brand-portal
make doctor

# 3. COMPLETE!
```

---

## 📦 Creating Your Dotfiles Repository

### Step 1: Prepare Local Machine
```bash
# Backup current configs
mkdir -p ~/dotfiles-backup
cp ~/.bashrc ~/dotfiles-backup/ 2>/dev/null || true
cp ~/.gitconfig ~/dotfiles-backup/ 2>/dev/null || true
cp ~/.zshrc ~/dotfiles-backup/ 2>/dev/null || true
```

### Step 2: Create Dotfiles Repo
```bash
# Create directory
mkdir ~/flowtrain-dotfiles
cd ~/flowtrain-dotfiles

# Initialize git
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Create structure
mkdir -p config scripts wsl windows
touch README.md install.sh install-wsl.sh .gitignore
chmod +x install.sh install-wsl.sh
```

### Step 3: Add Configuration Files

**config/.bashrc** (additions to existing bashrc):
```bash
# Development shortcuts
alias projects='cd ~/projects'
alias dotfiles='cd ~/.dotfiles'
alias flowtrain='cd ~/projects/brand-portal'
alias ll='ls -lh'
alias la='ls -lah'

# Quick commands
alias reload='source ~/.bashrc'
alias bundle-setup='bundle config set --local path ".bundle/gems"'
alias jekyll-serve='bundle exec jekyll serve'

# Release commands
alias release='bash ~/projects/brand-portal/scripts/ship-improved.sh'
alias release-dry='bash ~/projects/brand-portal/scripts/ship-improved.sh --dry-run'

# GitHub CLI functions
gh-clone() {
    gh repo clone "$1" ~/projects/$(basename "$1")
}

# Load environment if it exists
[ -f ~/.env.local ] && source ~/.env.local
```

**config/.gitconfig** (global git settings):
```ini
[user]
    name = Your Name
    email = your.email@example.com

[core]
    editor = nano
    autocrlf = input

[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = log --graph --oneline --all

[credential]
    helper = gh auth git-credential

[pull]
    rebase = false

[push]
    default = current
```

**wsl/apt-packages.txt**:
```
build-essential
curl
wget
git
zsh
vim
nano
htop
zip
unzip
p7zip-full
make
ruby-full
ruby-dev
bundler
```

**install-wsl.sh**:
```bash
#!/bin/bash
set -euo pipefail

echo "Installing WSL development environment..."

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install packages from list
echo "Installing packages..."
while IFS= read -r package; do
    [ -z "$package" ] && continue
    sudo apt-get install -y "$package"
done < "$(dirname "$0")/wsl/apt-packages.txt"

# Install GitHub CLI if not present
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.githubusercontent.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.githubusercontent.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt update
    sudo apt install -y gh
fi

# Create directories
mkdir -p ~/projects ~/.config

# Apply configurations
echo "Applying configurations..."
cp -v "$(dirname "$0")/config/.bashrc" ~/.bashrc || true
cp -v "$(dirname "$0")/config/.gitconfig" ~/.gitconfig || true

# Create env template if not exists
if [ ! -f ~/.env.local ]; then
    cat > ~/.env.local << 'ENVEOF'
# GitHub token (DO NOT COMMIT)
# export GH_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Project settings
export FLOWTRAIN_ORG="FlowTrain"
export FLOWTRAIN_REPO="brand-portal"
export FLOWTRAIN_PROJECTS="$HOME/projects"
ENVEOF
    chmod 600 ~/.env.local
    echo "Created ~/.env.local (update with your PAT token)"
fi

# Initialize GitHub if needed
if ! gh auth status >/dev/null 2>&1; then
    echo "Please authenticate with GitHub:"
    gh auth login
fi

# Setup git credential helper
gh auth setup-git

echo "✅ WSL setup complete!"
echo
echo "Next steps:"
echo "1. Edit ~/.env.local with your GitHub PAT token"
echo "2. Clone FlowTrain repo: gh repo clone FlowTrain/brand-portal ~/projects/brand-portal"
echo "3. Test: make doctor"
```

### Step 4: Create .gitignore
```
# Local configurations
.env.local
*.private
.env*.local

# System files
.DS_Store
Thumbs.db
*.swp
*~

# Temporary files
*.tmp
*.bak
*.backup

# Sensitive data
.ssh/
.gnupg/
.config/gh/hosts.yml

# Dependencies
node_modules/
.bundle/

# IDE
.vscode/
.idea/
*.code-workspace
```

### Step 5: Push to GitHub
```bash
cd ~/flowtrain-dotfiles

# Add all files
git add .

# Commit
git commit -m "Initial dotfiles setup for FlowTrain development"

# Create GitHub repo and push
gh repo create flowtrain-dotfiles --source=. --remote=origin --push

# Verify
git remote -v
```

---

## 🔄 Using Dotfiles on New Machine

```bash
# 1. Clone dotfiles
git clone https://github.com/YourUsername/flowtrain-dotfiles.git ~/.dotfiles

# 2. Run setup
bash ~/.dotfiles/install-wsl.sh

# 3. Update environment
nano ~/.env.local
# Add your GitHub PAT token

# 4. Reload shell
source ~/.bashrc

# 5. Clone FlowTrain
gh repo clone FlowTrain/brand-portal ~/projects/brand-portal

# 6. Verify
cd ~/projects/brand-portal
make doctor
```

---

## 📊 File Organization

### Your Dotfiles Repo Structure
```
~/.dotfiles/
├── README.md                # How to use this repo
├── install-wsl.sh          # Setup automation
├── .gitignore              # What not to track
│
├── config/
│   ├── .bashrc             # Shell configuration
│   ├── .gitconfig          # Git configuration
│   └── .zshrc              # Zsh config (optional)
│
├── wsl/
│   └── apt-packages.txt    # All packages to install
│
└── scripts/                # Helper scripts (optional)
    ├── verify-setup.sh
    └── update-tools.sh
```

### Your Project Directory Structure
```
~/projects/
├── brand-portal/           # Main FlowTrain repo
│   ├── SETUP_GUIDE.md
│   ├── DOTFILES_GUIDE.md
│   ├── PAT_MANAGEMENT.md
│   ├── RELEASE_*.md
│   ├── scripts/
│   ├── Makefile
│   └── website/
│
└── [other repos]           # Clone other projects here
```

---

## 🔐 Security Checklist

### Dotfiles Repository
- [ ] ✅ Created .gitignore to exclude secrets
- [ ] ✅ NO credentials committed
- [ ] ✅ .env.local is local-only
- [ ] ✅ PAT token stored separately
- [ ] ✅ Repository is private (optional but recommended)

### Local Machine
- [ ] ✅ ~/.env.local has 600 permissions
- [ ] ✅ PAT token only in memory or password manager
- [ ] ✅ SSH keys secured (if using SSH)
- [ ] ✅ Firewall enabled on Windows 11

---

## 📅 Maintenance Schedule

### Weekly
```bash
# Update system packages
sudo apt-get update && sudo apt-get upgrade

# Update dotfiles
cd ~/.dotfiles && git pull
```

### Monthly
```bash
# Update all development tools
gh --version  # Check for updates
ruby --version
git --version

# Verify setup
make doctor
```

### Quarterly
- [ ] Verify GitHub PAT token still works
- [ ] Check GitHub security log
- [ ] Review installed packages
- [ ] Test dotfiles on test machine

### Before Expiration (April 1, 2026)
- [ ] Create new GitHub PAT token
- [ ] Test with release pipeline
- [ ] Delete old token
- [ ] Update calendar for next renewal (90 days)

---

## 🆘 Troubleshooting

### Can't Clone Dotfiles Repo
```bash
# Verify GitHub authentication
gh auth status

# Try manual clone
git clone git@github.com:YourUsername/flowtrain-dotfiles.git ~/.dotfiles
```

### Setup Script Fails
```bash
# Run with verbose output
bash -x ~/.dotfiles/install-wsl.sh

# Check permissions
ls -la ~/.dotfiles/install-wsl.sh
chmod +x ~/.dotfiles/install-wsl.sh
```

### .env.local Not Loading
```bash
# Verify it's sourced in ~/.bashrc
grep ".env.local" ~/.bashrc

# Check file exists and has correct permissions
ls -la ~/.env.local  # Should show: -rw------- (600)

# Reload shell
source ~/.bashrc
```

---

## 📝 Device Setup Checklist

### Initial Setup (Day 1)
- [ ] Windows 11 installed
- [ ] WSL2 enabled
- [ ] WSL Ubuntu 22.04 running
- [ ] All required tools installed
- [ ] GitHub CLI authenticated
- [ ] FlowTrain repo cloned
- [ ] `make doctor` passes

### Dotfiles Setup (Day 1-2)
- [ ] Created dotfiles repository
- [ ] Pushed to GitHub
- [ ] Tested restore from scratch
- [ ] Documented setup process
- [ ] Added to password manager (PAT token backup)

### Ongoing Maintenance
- [ ] Monthly package updates
- [ ] Quarterly security review
- [ ] **April 1, 2026: PAT renewal**
- [ ] Annual full system backup

---

## 🎯 Quick Start Templates

### For New Developer on Team
Share this:
```
1. Clone dotfiles: git clone https://github.com/YourUsername/flowtrain-dotfiles.git ~/.dotfiles
2. Run setup: bash ~/.dotfiles/install-wsl.sh
3. Update ~/.env.local with your GitHub PAT
4. Clone repo: gh repo clone FlowTrain/brand-portal ~/projects/brand-portal
5. Verify: make doctor
```

### For Machine Refresh
```
# Backup current setup
cp -r ~/.dotfiles ~/dotfiles-backup-$(date +%Y%m%d)

# Update from repo
cd ~/.dotfiles && git pull

# Re-apply config
bash install-wsl.sh
```

---

## 📞 Support Resources

| Topic | Resource |
|-------|----------|
| WSL Setup | [SETUP_GUIDE.md](SETUP_GUIDE.md) |
| Dotfiles Creation | [DOTFILES_GUIDE.md](DOTFILES_GUIDE.md) |
| PAT Renewal | [PAT_MANAGEMENT.md](PAT_MANAGEMENT.md) |
| Release Pipeline | [RELEASE_GUIDE.md](RELEASE_GUIDE.md) |
| GitHub CLI | https://cli.github.com/ |
| WSL Docs | https://learn.microsoft.com/en-us/windows/wsl/ |

---

**Created**: 2026-01-17  
**Updated**: 2026-01-17  
**Status**: ✅ Ready for Production  
**Next Review**: 2026-04-01 (PAT Renewal Reminder)

# FlowTrain Development Dotfiles Repository

This is a template for creating a `.dotfiles` repository to quickly set up your development environment on any Windows 11 + WSL machine.

## Structure

```
flowtrain-dotfiles/
├── README.md                    # Overview and quick start
├── install.sh                   # Main installation script
├── install-windows.ps1          # Windows setup script
├── install-wsl.sh               # WSL setup script
│
├── config/
│   ├── .bashrc                  # Bash configuration
│   ├── .zshrc                   # ZsAllnfiguration
│   └── .vimrc                   # Vim configuration (optional)
│
├── scripts/
│   ├── setup-ruby.sh            # Ruby installation
│   ├── setup-gh-cli.sh          # GitHub CLI setup
│   ├── setup-dev-tools.sh       # Dev tools installation
│   └── post-install.sh          # Post-installation checks
│
├── windows/
│   ├── InstallChocolatey.ps1    # Chocolatey setup
│   ├── InstallWindowsApps.ps1   # Windows app installation
│   └── profile.ps1              # PowerShell profile
│
└── wsl/
    ├── apt-packages.txt         # List of apt packages to install
    └── ubuntu-setup.sh          # Ubuntu-specific setup
```

## How to Use

### On New Windows 11 Machine

```powershell
# 1. Clone dotfiles
git clone https://github.com/YourUsername/flowtrain-dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run Windows installer (as Administrator)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install-windows.ps1

# 3. Enable WSL and restart
wsl --install
# Restart computer

# 4. Open WSL terminal
wsl

# 5. Run WSL installer
bash ~/.dotfiles/install-wsl.sh
```

### On Existing WSL Setup

```bash
# Clone dotfiles to home
git clone https://github.com/YourUsername/flowtrain-dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run setup
bash install-wsl.sh

# Apply configurations
bash scripts/post-install.sh
```

## File Contents (Templates)

### install.sh
```bash
#!/bin/bash
# Main orchestrator - calls appropriate scripts based on OS

OS_TYPE=$(uname -s)

if [[ "$OS_TYPE" == "Linux" ]]; then
    echo "Installing on Linux/WSL..."
    bash scripts/setup-dev-tools.sh
    bash scripts/setup-ruby.sh
    bash scripts/setup-gh-cli.sh
    bash scripts/post-install.sh
else
    echo "Unsupported OS: $OS_TYPE"
    exit 1
fi
```

### wsl/apt-packages.txt
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
# Add more as needed
```

## Quick Reference Files

### ~/.bashrc additions
```bash
# Development shortcuts
alias projects='cd ~/projects'
alias dotfiles='cd ~/.dotfiles'
alias flowtrain='cd ~/projects/brand-portal'

# Quick commands
alias ll='ls -lh'
alias la='ls -lah'
alias reload-profile='source ~/.bashrc'

# Git shortcuts
gh-clone() { gh repo clone "$1" ~/projects/$(basename "$1"); }

# Quick release
alias release='bash ~/projects/brand-portal/scripts/ship-improved.sh'
alias release-dry='bash ~/projects/brand-portal/scripts/ship-improved.sh --dry-run'
```

### ~/.gitconfig additions
```ini
[core]
    editor = nano
    autocrlf = input  # Important for WSL

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
```

## Important: Environment Variables

Create `~/.env.local` (not tracked in git):

```bash
# GitHub PAT (DO NOT COMMIT)
export GH_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Project settings
export FLOWTRAIN_ORG="FlowTrain"
export FLOWTRAIN_REPO="brand-portal"
export FLOWTRAIN_PROJECTS="$HOME/projects"
```

Load in `~/.bashrc`:
```bash
if [ -f ~/.env.local ]; then
    source ~/.env.local
fi
```

## Creating Your Dotfiles Repository

### Step 1: Initialize Repository
```bash
mkdir ~/flowtrain-dotfiles
cd ~/flowtrain-dotfiles
git init
```

### Step 2: Create Structure
```bash
mkdir -p config scripts windows wsl
touch README.md install.sh install-windows.ps1 install-wsl.sh
chmod +x *.sh
```

### Step 3: Add to GitHub
```bash
cd ~/flowtrain-dotfiles
git add .
git commit -m "Initial dotfiles setup"
git remote add origin https://github.com/YourUsername/flowtrain-dotfiles.git
git push -u origin main
```

### Step 4: Keep Updated
```bash
# Link real config files (optional)
ln -s ~/.dotfiles/config/.bashrc ~/.bashrc
ln -s ~/.dotfiles/config/.gitconfig ~/.gitconfig

# Or copy and track separately
cp ~/.bashrc ~/.dotfiles/config/.bashrc
```

## Backup Your Current Setup

Before creating new files, backup your existing config:

```bash
# Backup existing configs
mkdir -p ~/.dotfiles-backup
cp ~/.bashrc ~/.dotfiles-backup/
cp ~/.gitconfig ~/.dotfiles-backup/
cp -r ~/.config/gh ~/.dotfiles-backup/

# Store PAT safely (NOT in dotfiles!)
# Keep in 1Password, LastPass, or secure note
```

## Security Notes

### DO NOT COMMIT
- GitHub PAT tokens
- SSH keys
- Private configuration
- Sensitive credentials

### Use .gitignore
```
.env.local
*.private
.ssh/
.gnupg/
.config/gh/hosts.yml  # Contains token
*.backup
```

### Safe Credential Handling
```bash
# Never hardcode secrets
# Instead, source from external file
if [ -f ~/.env.local ]; then
    source ~/.env.local  # Not tracked in git
fi
```

## Maintenance

### Monthly
```bash
cd ~/.dotfiles
git pull
# Review any changes

sudo apt-get update
sudo apt-get upgrade
```

### Review Checklist
- [ ] Dotfiles repository synced
- [ ] All tools updated
- [ ] PAT token valid (expires 90 days)
- [ ] No secrets committed

## Next Steps

1. Create your dotfiles repository on GitHub
2. Copy templates from this guide
3. Customize for your workflow
4. Test on new machine or WSL reset
5. Share with team (without secrets!)

---

**Template Updated**: 2026-01-17  
**Status**: Ready to Use  
**Security Level**: ✅ Production Ready

# 🚄 FlowTrain Release Guide

Complete guide for publishing FlowTrain releases (v1.0.1 and beyond).

## Prerequisites

- **WSL/Linux environment** with bash
- **Git** configured for the repository
- **GitHub CLI** (`gh`) installed and authenticated
- **Ruby** 3.0+ with bundler for Jekyll builds
- **zip** and **7z** utilities for compression

## Quick Setup (One-Time)

### 1. Install GitHub CLI
```bash
# On Ubuntu/Debian
sudo apt-get update && sudo apt-get install gh -y

# Verify installation
gh version
```

### 2. Authenticate with GitHub
```bash
# Create a Personal Access Token (PAT) at https://github.com/settings/tokens
# Required scopes: repo, workflow, read:org

# Authenticate gh CLI
gh auth login
# Select: GitHub.com
# Select: HTTPS
# Paste your PAT when prompted

# Verify authentication
gh auth status
```

### 3. Set Up Git Credential Helper
```bash
# Configure git to use gh for authentication
gh auth setup-git

# Verify configuration
git config --global --list | grep credential
```

### 4. Install Ruby Dependencies
```bash
cd website/microsite

# Install bundler if not already present
gem install bundler

# Install gems locally
bundle config set --local path '.bundle/gems'
bundle install

# Verify Jekyll is installed
bundle exec jekyll --version
```

## Release Workflow

### Option A: Automated Pipeline (Recommended)

Run the complete release pipeline with one command:

```bash
bash scripts/ship-1.0.1.sh
```

This executes (in order):
1. Verify all prerequisites
2. Sync to main branch
3. Place microsite assets (banner, SVG wordmark)
4. Package all bundles (ZIP + 7Z)
5. Generate checksums
6. Create release notes
7. Verify everything (site builds, packages exist, checksums match)
8. Publish GitHub release with assets
9. Create PR for microsite updates

### Option B: Step-by-Step Manual Release

If you prefer more control, run each step individually:

#### Step 1: Verify System
```bash
make doctor
```

#### Step 2: Place Assets
```bash
make assets
```

#### Step 3: Create Packages
```bash
make package      # Creates .zip archives
make package-7z   # Creates .7z archives
make checksums    # Generates SHA256SUMS.txt
```

#### Step 4: Generate Notes
```bash
make notes-template TAG=v1.0.1
```

#### Step 5: Verify Release
```bash
make verify
```

#### Step 6: Publish Release
```bash
make release TAG=v1.0.1 TITLE="v1.0.1 — Microsite + System Assets"
```

#### Step 7: Create PR
```bash
git checkout -b feature/microsite-v1.0.1
git add website/microsite
git commit -m "Microsite: finalize banner (+15% trails), embed SVG wordmark, wire downloads for v1.0.1"

# Push with PAT token
TOKEN=$(grep oauth_token ~/.config/gh/hosts.yml | awk '{print $2}')
git push "https://FlowTrain:${TOKEN}@github.com/FlowTrain/brand-portal.git" feature/microsite-v1.0.1

# Create PR
gh pr create --title "Microsite: finalize banner & downloads for v1.0.1" \
             --body "Wires banner, SVG wordmark, and downloads for v1.0.1."
```

## Available Make Targets

| Target | Purpose |
|--------|---------|
| `make help` | Show all available targets |
| `make doctor` | Verify system setup and required files |
| `make assets` | Place banner and SVG wordmark |
| `make package` | Create ZIP archives for all packages |
| `make package-7z` | Create 7Z archives for all packages |
| `make checksums` | Generate SHA256 checksums |
| `make notes-template` | Draft release notes |
| `make verify` | Comprehensive validation (Jekyll build, packages, checksums, notes) |
| `make release` | Publish GitHub release with all assets |
| `make pr-microsite` | Open PR for microsite updates |
| `make clean` | Remove generated release artifacts |

## Troubleshooting

### GitHub Authentication Fails

**Problem**: `git push` asks for password despite gh authentication

**Solution**:
```bash
# Re-authenticate gh
gh auth logout
gh auth login

# Re-setup git credential helper
gh auth setup-git

# Clear any cached credentials
git credential reject <<'EOF'
protocol=https
host=github.com
EOF
```

### Jekyll Build Fails ("minima theme not found")

**Solution**: The `_config.yml` should NOT have a `theme: minima` line. If you see this error:
```bash
# Remove the theme line from _config.yml
sed -i '/^theme:/d' website/microsite/_config.yml

# Rebuild
make verify
```

### Zip Files Not Created ("I/O error")

**Problem**: Relative paths fail for motion directory

**Solution**: Ensure the motion directory exists:
```bash
mkdir -p motion
echo "Motion assets placeholder" > motion/README.md
```

### Release Already Exists

**Problem**: `gh release create` says release already exists

**Solution**: This is expected if re-running. The ship script handles this gracefully. To delete and re-publish:
```bash
gh release delete v1.0.1 --repo FlowTrain/brand-portal --yes
bash scripts/ship-1.0.1.sh
```

## Release File Structure

After a successful release:

```
release/
└── v1.0.1/
    ├── FlowTrain_Windows_ThemePack.zip
    ├── FlowTrain_Windows_ThemePack.7z
    ├── FlowTrain_macOS_Wallpapers.zip
    ├── FlowTrain_macOS_Wallpapers.7z
    ├── FlowTrain_Cursor_Set.zip
    ├── FlowTrain_Cursor_Set.7z
    ├── FlowTrain_Notion_Kit.zip
    ├── FlowTrain_Notion_Kit.7z
    ├── FlowTrain_Confluence_Kit.zip
    ├── FlowTrain_Confluence_Kit.7z
    ├── FlowTrain_GitHub_Kit.zip
    ├── FlowTrain_GitHub_Kit.7z
    ├── FlowTrain_Motion_Assets.zip
    ├── FlowTrain_Motion_Assets.7z
    ├── FlowTrain_Microsite_Assets.zip
    ├── FlowTrain_Microsite_Assets.7z
    └── SHA256SUMS.txt
```

## GitHub Release Details

- **Release URL**: `https://github.com/FlowTrain/brand-portal/releases/tag/v1.0.1`
- **Assets**: 16 files (8 ZIP + 8 7Z)
- **Checksums**: SHA256SUMS.txt attached to release
- **Notes**: Generated from scripts/release-notes-v1.0.1.md

## Key Files Modified

- **Makefile** (auto-generated) - Build orchestration
- **scripts/write-makefile.sh** - Makefile template generator
- **scripts/ship-1.0.1.sh** - Complete release pipeline
- **scripts/release-notes-v1.0.1.md** - Release notes (auto-generated)
- **website/microsite/Gemfile** - Ruby dependencies (Jekyll 3.9.0)
- **website/microsite/_config.yml** - Jekyll configuration

## For Next Releases

To prepare for v1.0.2 or beyond:

1. Duplicate the ship script: `cp scripts/ship-1.0.1.sh scripts/ship-1.0.2.sh`
2. Update TAG variable: `sed -i 's/v1.0.1/v1.0.2/g' scripts/ship-1.0.2.sh`
3. Run: `bash scripts/ship-1.0.2.sh`

## Environment Variables

Configure via environment or script parameters:

| Variable | Default | Purpose |
|----------|---------|---------|
| `TAG` | v1.0.1 | Release version tag |
| `ORG` | FlowTrain | GitHub organization |
| `REPO` | brand-portal | Repository name |
| `DRY_RUN` | false | Preview without publishing |

Example with dry-run:
```bash
DRY_RUN=true bash scripts/ship-1.0.1.sh
```

## Support

For issues or improvements:
1. Check troubleshooting section above
2. Review Makefile targets: `make help`
3. Check gh CLI status: `gh auth status`
4. Verify system: `make doctor`

---

**Last Updated**: 2026-01-17 | **Status**: Production Ready ✅

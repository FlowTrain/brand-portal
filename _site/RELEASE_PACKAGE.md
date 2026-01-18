# 📦 FlowTrain Release Package Documentation

Complete release automation and documentation package for FlowTrain v1.0.1 and beyond.

---

## 📋 What's Included

### Documentation
- **`RELEASE_GUIDE.md`** - Complete step-by-step release workflow guide
- **`RELEASE_CHEATSHEET.md`** - Quick reference for common tasks
- **`RELEASE_PACKAGE.md`** - This file

### Scripts

#### 1. **`scripts/ship-1.0.1.sh`** (Original)
- Basic release automation
- Handles: packaging, checksums, notes, verification, release publishing
- 107 lines
- Use when: You understand the workflow and want straightforward automation

#### 2. **`scripts/ship-improved.sh`** (Enhanced)
- Improved version with better error handling
- Better git credential authentication (fixes HTTPS auth issues)
- Colored output and detailed logging
- Dry-run mode (`--dry-run` flag)
- Environment variable configuration
- 337 lines
- **Recommended for production use**

#### 3. **`Makefile`** (Auto-generated)
- Auto-generated from `scripts/write-makefile.sh` template
- Manages: packaging, checksums, Jekyll builds, release publishing
- 12+ targets for fine-grained control
- Run `make help` to see all options

#### 4. **`scripts/write-makefile.sh`** (Template Generator)
- Generates `Makefile` from template
- Handles: tab conversion, backslash continuations, line formatting
- Re-run if you update Makefile rules: `bash scripts/write-makefile.sh`

---

## 🚀 Quick Start

### First Time Setup (5 minutes)
```bash
# 1. Install GitHub CLI
sudo apt-get install gh -y

# 2. Authenticate
gh auth login
gh auth setup-git

# 3. Install Ruby dependencies
cd website/microsite
bundle config set --local path '.bundle/gems'
bundle install
cd ../..

# 4. Verify setup
make doctor
```

### One-Command Release
```bash
# Full automated release
bash scripts/ship-1.0.1.sh

# Or with improved error handling
bash scripts/ship-improved.sh

# Or dry-run (preview only)
bash scripts/ship-improved.sh --dry-run
```

---

## 📚 Documentation Map

### For Getting Started
→ Start here: **`RELEASE_GUIDE.md`** - Prerequisites section

### For Quick Reference
→ Use: **`RELEASE_CHEATSHEET.md`** - Common commands and fixes

### For Detailed Workflow
→ Read: **`RELEASE_GUIDE.md`** - Full workflow section

### For Troubleshooting
→ Check: **`RELEASE_GUIDE.md`** - Troubleshooting section

### For Advanced Control
→ Use: Individual `make` targets with `make help`

---

## 🔄 Release Workflow Overview

```
┌─────────────────────────────────┐
│  Preflight Checks               │ → Verify: git, gh, ruby, make
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Sync Main Branch               │ → Pull latest from origin
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Place Assets                   │ → Banner, SVG wordmark
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Package Bundles                │ → ZIP + 7Z archives
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Generate Checksums             │ → SHA256SUMS.txt
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Create Release Notes            │ → Auto-generated from assets
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Verify Everything              │ → Build, packages, checksums
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Publish GitHub Release         │ → Create release + upload assets
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Create Pull Request            │ → For microsite updates
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  Report URLs                    │ → Release + PR links
└─────────────────────────────────┘
```

---

## 📊 Generated Artifacts

After a successful release in `release/v1.0.1/`:

```
16 files:
├── 8 ZIP files (standard format)
│   ├── FlowTrain_Windows_ThemePack.zip
│   ├── FlowTrain_macOS_Wallpapers.zip
│   ├── FlowTrain_Cursor_Set.zip
│   ├── FlowTrain_Notion_Kit.zip
│   ├── FlowTrain_Confluence_Kit.zip
│   ├── FlowTrain_GitHub_Kit.zip
│   ├── FlowTrain_Motion_Assets.zip
│   └── FlowTrain_Microsite_Assets.zip
├── 8 7Z files (compressed format)
│   └── [Same names as above with .7z extension]
└── SHA256SUMS.txt (checksums for all 16 files)
```

**Total Size**: ~15-30 KB (mostly placeholders; Microsite_Assets contains actual Jekyll build)

---

## 🛠️ Common Tasks

### View Current Release
```bash
gh release view v1.0.1 --repo FlowTrain/brand-portal
```

### Check PR Status
```bash
gh pr list --repo FlowTrain/brand-portal --state open
```

### Regenerate Makefile
```bash
bash scripts/write-makefile.sh
```

### Clean Up (Remove Artifacts)
```bash
make clean
```

### Update for New Version
```bash
# Example: Create v1.0.2 release
cp scripts/ship-1.0.1.sh scripts/ship-1.0.2.sh
sed -i 's/v1.0.1/v1.0.2/g' scripts/ship-1.0.2.sh
bash scripts/ship-1.0.2.sh
```

---

## 🔑 Key Configuration Files

| File | Purpose | Key Settings |
|------|---------|--------------|
| `Makefile` | Build automation | 12+ targets, TAG, ORG, REPO vars |
| `website/microsite/Gemfile` | Ruby gems | Jekyll 3.9.0, bundler |
| `website/microsite/_config.yml` | Jekyll config | title, markdown: kramdown |
| `scripts/release-notes-v1.0.1.md` | Release notes | Auto-generated, lists all assets |
| `~/.config/gh/hosts.yml` | GitHub auth | OAuth token (auto-created) |

---

## ⚠️ Important Notes

### Git Credential Authentication
- **Issue**: Git HTTPS auth fails even with gh authentication
- **Solution**: Use PAT token directly or run `gh auth setup-git`
- **Improved script**: Handles this automatically with proper error handling

### Jekyll Theme Issue
- **Issue**: "minima theme could not be found"
- **Solution**: Ensure `_config.yml` does NOT have `theme: minima` line
- **Status**: Already fixed in current setup

### Relative Path Issues
- **Issue**: Zip I/O errors for motion directory
- **Solution**: Ensure `motion/` directory exists
- **Status**: Handled by SAFE_ZIP macro in Makefile

### Release Already Exists
- **Issue**: `gh release create` fails if version already published
- **Solution**: Delete and re-create, or just re-run (error is caught)
- **Status**: Script handles gracefully

---

## 📞 Support & Troubleshooting

### Step 1: Check System
```bash
make doctor
```

### Step 2: Check Authentication
```bash
gh auth status
```

### Step 3: Check Logs
```bash
# Verbose output
bash scripts/ship-1.0.1.sh 2>&1 | tee release.log
```

### Step 4: Check Documentation
→ See `RELEASE_GUIDE.md` Troubleshooting section

---

## 📈 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-01-17 | Initial release with microsite, themes, docs kits |
| 1.0.2 (planned) | TBD | Fonts, ultrawide banner, motion refinements |

---

## 🎯 Next Steps After Release

1. **Merge PR #3** - Review and merge microsite updates
2. **Verify Live Release** - Visit GitHub release page
3. **Update Downloads Page** - Wire v1.0.1 links
4. **Share Release** - Announce to users
5. **Plan v1.0.2** - Start next release cycle

---

## 📄 License & Attribution

Release automation for FlowTrain brand portal.
Created: January 17, 2026
Repository: https://github.com/FlowTrain/brand-portal

---

## 🔗 Quick Links

- **Release**: https://github.com/FlowTrain/brand-portal/releases/tag/v1.0.1
- **Pull Request**: https://github.com/FlowTrain/brand-portal/pull/3
- **Repository**: https://github.com/FlowTrain/brand-portal
- **GitHub CLI**: https://cli.github.com/
- **Jekyll**: https://jekyllrb.com/

---

**For detailed instructions, see `RELEASE_GUIDE.md`**  
**For quick reference, see `RELEASE_CHEATSHEET.md`**

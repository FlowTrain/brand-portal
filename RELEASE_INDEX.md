# 📚 FlowTrain Release Documentation Index

Welcome! This is your complete guide to the FlowTrain release process.

## 🎯 Start Here

**New to releasing?** → Read [`RELEASE_GUIDE.md`](RELEASE_GUIDE.md) first

**Need quick reference?** → Use [`RELEASE_CHEATSHEET.md`](RELEASE_CHEATSHEET.md)

**Want full details?** → See [`RELEASE_PACKAGE.md`](RELEASE_PACKAGE.md)

---

## 📖 Documentation Guide

### [`RELEASE_GUIDE.md`](RELEASE_GUIDE.md) (7.3 KB)
**Complete release workflow guide**

- **Prerequisites**: Setup GitHub CLI, authentication, Ruby dependencies
- **Quick Setup**: One-time configuration (5 minutes)
- **Release Workflow**: 
  - Option A: Automated pipeline (recommended)
  - Option B: Step-by-step manual release
- **Make Targets**: Reference table of all available commands
- **Troubleshooting**: Solutions for common issues
- **For Next Releases**: How to adapt for v1.0.2+

**When to use**: First time releasing, detailed instructions needed

### [`RELEASE_CHEATSHEET.md`](RELEASE_CHEATSHEET.md) (2.7 KB)
**Quick reference for common tasks**

- **One-Command Release**: Copy-paste ready
- **Quick Diagnostics**: Verify system setup
- **Manual Step-by-Step**: For more control
- **Common Issues & Fixes**: Problem → Solution
- **File Locations**: Where everything is
- **Make Targets**: Quick reference table
- **Environment Variables**: Configuration options

**When to use**: You know the process and need quick commands, troubleshooting

### [`RELEASE_PACKAGE.md`](RELEASE_PACKAGE.md) (9.6 KB)
**Complete package documentation**

- **What's Included**: Documentation, scripts, generated files
- **Quick Start**: 5-minute setup + one-command release
- **Documentation Map**: Where to find what
- **Release Workflow Overview**: Visual flowchart
- **Generated Artifacts**: What gets created
- **Common Tasks**: Useful recipes
- **Key Configuration Files**: Important settings
- **Important Notes**: Gotchas and solutions
- **Version History**: Releases and planned updates
- **Quick Links**: Resources and URLs

**When to use**: Need complete overview, planning releases, reference

---

## 🚀 Quick Start (Copy-Paste Ready)

### First Time (Prerequisites)
```bash
# 1. Install GitHub CLI
sudo apt-get install gh -y

# 2. Authenticate
gh auth login
gh auth setup-git

# 3. Install dependencies
cd website/microsite
bundle config set --local path '.bundle/gems'
bundle install
cd ../..

# 4. Verify
make doctor
```

### Release (One Command)
```bash
# Run the complete pipeline
bash scripts/ship-1.0.1.sh

# OR: With better error handling and dry-run option
bash scripts/ship-improved.sh
bash scripts/ship-improved.sh --dry-run  # Preview only
```

---

## 📁 File Structure

```
root/
├── RELEASE_GUIDE.md              ← START HERE for setup & details
├── RELEASE_CHEATSHEET.md         ← Quick reference & fixes
├── RELEASE_PACKAGE.md            ← Complete documentation
├── RELEASE_INDEX.md              ← This file
│
├── scripts/
│   ├── ship-1.0.1.sh             ← Original release script
│   ├── ship-improved.sh          ← Enhanced version (recommended)
│   ├── write-makefile.sh          ← Makefile template generator
│   └── release-notes-v1.0.1.md   ← Auto-generated release notes
│
├── Makefile                       ← Build automation (auto-generated)
│
├── website/microsite/
│   ├── Gemfile                   ← Ruby dependencies
│   ├── _config.yml               ← Jekyll configuration
│   └── _site/                    ← Built site (generated)
│
└── release/v1.0.1/               ← Generated release artifacts
    ├── *.zip                     ← 8 ZIP archives
    ├── *.7z                      ← 8 7Z archives
    └── SHA256SUMS.txt            ← Checksums
```

---

## 🔄 Workflow

### Visual Flow
```
Setup (1 time)
    ↓
bash scripts/ship-1.0.1.sh  ← Main automation
    ├── ✓ Verify prerequisites
    ├── ✓ Sync branches
    ├── ✓ Package assets (ZIP + 7Z)
    ├── ✓ Generate checksums
    ├── ✓ Create release notes
    ├── ✓ Full verification
    ├── ✓ Publish release
    ├── ✓ Create PR
    └── ✓ Report URLs
        ↓
Review release & PR
        ↓
✅ DONE - Share with users
```

---

## 🎓 Learning Path

### I'm completely new to this
1. Read: [Prerequisites section in RELEASE_GUIDE.md](RELEASE_GUIDE.md#prerequisites)
2. Run: Quick Setup code above
3. Read: [Quick Setup section in RELEASE_GUIDE.md](RELEASE_GUIDE.md#quick-setup-one-time)
4. Run: `make doctor` to verify setup
5. Run: `bash scripts/ship-1.0.1.sh` for first release
6. **Bookmark**: [RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md) for next time

### I've released before, just need a reminder
1. Glance at: [RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md)
2. Run: `bash scripts/ship-1.0.1.sh`
3. Done!

### I want to understand the full pipeline
1. Read: [Release Workflow section in RELEASE_GUIDE.md](RELEASE_GUIDE.md#release-workflow)
2. Read: [Key Files section in RELEASE_PACKAGE.md](RELEASE_PACKAGE.md#-key-configuration-files)
3. Run: Individual `make` targets with `make help`

### I'm having issues
1. Check: [Troubleshooting in RELEASE_GUIDE.md](RELEASE_GUIDE.md#troubleshooting)
2. Check: [Common Issues in RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md#common-issues--fixes)
3. Try: `make doctor` and `gh auth status`

---

## 📝 Script Comparison

| Feature | ship-1.0.1.sh | ship-improved.sh |
|---------|---------------|-----------------|
| **Size** | 3.2 KB | 7.8 KB |
| **Features** | Basic pipeline | Full + error handling |
| **Git auth** | Uses `git push` | Uses PAT token directly |
| **Error handling** | Basic | Comprehensive |
| **Output colors** | None | Yes (colored) |
| **Dry-run mode** | No | Yes (`--dry-run`) |
| **Configuration** | Limited | Full env vars |
| **Recommended** | Learning | Production |

**Recommendation**: Use `scripts/ship-improved.sh` for actual releases

---

## 💡 Pro Tips

### 1. Dry-Run First
```bash
bash scripts/ship-improved.sh --dry-run
# See what would happen without making changes
```

### 2. Check Make Targets
```bash
make help
# See all available commands
```

### 3. System Verification
```bash
make doctor
# Verify everything is set up correctly
```

### 4. View Release Info
```bash
gh release view v1.0.1 --repo FlowTrain/brand-portal
# See what was published
```

### 5. Check PR Status
```bash
gh pr list --repo FlowTrain/brand-portal --state open
# See open PRs
```

---

## 🆘 Need Help?

### Issue: Command not found
→ Run setup from [Quick Start](#quick-start-copy-paste-ready)

### Issue: Authentication fails  
→ See [Troubleshooting in RELEASE_GUIDE.md](RELEASE_GUIDE.md#troubleshooting)

### Issue: Build fails
→ Check [Common Issues in RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md#common-issues--fixes)

### Issue: Don't know what to do
→ Read [RELEASE_GUIDE.md](RELEASE_GUIDE.md) Prerequisites section

---

## 🔗 Important Links

- **GitHub Release**: https://github.com/FlowTrain/brand-portal/releases/tag/v1.0.1
- **Pull Request**: https://github.com/FlowTrain/brand-portal/pull/3
- **Repository**: https://github.com/FlowTrain/brand-portal
- **GitHub CLI Docs**: https://cli.github.com/
- **Jekyll Docs**: https://jekyllrb.com/

---

## 📞 Support Resources

| Need | Resource |
|------|----------|
| Setup help | [RELEASE_GUIDE.md Prerequisites](RELEASE_GUIDE.md#prerequisites) |
| Release commands | [RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md) |
| Troubleshooting | [RELEASE_GUIDE.md Troubleshooting](RELEASE_GUIDE.md#troubleshooting) |
| All details | [RELEASE_PACKAGE.md](RELEASE_PACKAGE.md) |
| Make targets | `make help` |
| System check | `make doctor` |
| Auth status | `gh auth status` |

---

## ✅ Checklist: First Release

- [ ] Read Prerequisites section in RELEASE_GUIDE.md
- [ ] Run Quick Setup (install gh, auth, ruby deps)
- [ ] Verify setup: `make doctor`
- [ ] Dry-run: `bash scripts/ship-improved.sh --dry-run`
- [ ] Full release: `bash scripts/ship-improved.sh`
- [ ] Check release URL in terminal output
- [ ] Review and merge PR #3
- [ ] Share release with users ✨

---

## 📅 Next Steps

1. **Choose your documentation**
   - New user? → [RELEASE_GUIDE.md](RELEASE_GUIDE.md)
   - Quick reference? → [RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md)
   - Complete details? → [RELEASE_PACKAGE.md](RELEASE_PACKAGE.md)

2. **Set up your environment** (first time only)
   - Follow Quick Setup above

3. **Run your first release**
   - `bash scripts/ship-improved.sh`

4. **Bookmark this for later**
   - [RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md) has quick commands

---

**Last Updated**: 2026-01-17  
**Status**: ✅ Production Ready  
**Version**: 1.0.1

For questions or improvements, refer to RELEASE_GUIDE.md or RELEASE_CHEATSHEET.md.

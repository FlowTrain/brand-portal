# 🚄 FlowTrain Release Cheat Sheet

## One-Command Release

```bash
bash scripts/ship-1.0.1.sh
```

## Quick Diagnostics

```bash
# Check system setup
make doctor

# Check GitHub auth
gh auth status

# Verify all make targets
make help
```

## Manual Step-by-Step

```bash
# 1. Verify everything
make doctor

# 2. Create packages
make package              # ZIP files
make package-7z          # 7Z files
make checksums           # SHA256SUMS.txt

# 3. Build and verify
make notes-template TAG=v1.0.1
make verify TAG=v1.0.1

# 4. Publish
make release TAG=v1.0.1

# 5. Create PR
git checkout -b feature/microsite-v1.0.1
git add website/microsite
git commit -m "Microsite updates for v1.0.1"
git push -u origin feature/microsite-v1.0.1
gh pr create --title "Microsite: v1.0.1" --body "Release updates"
```

## Common Issues & Fixes

### Git authentication fails
```bash
gh auth setup-git
gh auth logout && gh auth login
```

### Jekyll build fails
```bash
cd website/microsite
bundle install
bundle exec jekyll build
```

### Zip file errors
```bash
mkdir -p motion
echo "placeholder" > motion/README.md
make package
```

### Release already exists
```bash
gh release delete v1.0.1 --yes
bash scripts/ship-1.0.1.sh
```

## File Locations

| File | Purpose |
|------|---------|
| `scripts/ship-1.0.1.sh` | Main release automation |
| `scripts/ship-improved.sh` | Enhanced version with better error handling |
| `Makefile` | Build orchestration (auto-generated) |
| `scripts/write-makefile.sh` | Makefile template |
| `scripts/release-notes-v1.0.1.md` | Release notes (auto-generated) |
| `website/microsite/Gemfile` | Ruby dependencies |
| `release/v1.0.1/` | Generated artifacts |

## Make Targets Quick Reference

```bash
make help              # Show all targets
make doctor            # Verify setup
make assets            # Place banner/SVG
make package           # Create ZIP files
make package-7z        # Create 7Z files
make checksums         # Generate SHA256SUMS
make notes-template    # Draft release notes
make verify            # Full validation
make release           # Publish to GitHub
make clean             # Remove artifacts
```

## Environment Variables

```bash
# Custom release tag
TAG=v1.0.2 bash scripts/ship-1.0.1.sh

# Dry-run (preview only)
DRY_RUN=true bash scripts/ship-1.0.1.sh

# Custom org/repo
ORG=MyOrg REPO=my-repo bash scripts/ship-1.0.1.sh
```

## Links

- **Release**: https://github.com/FlowTrain/brand-portal/releases/tag/v1.0.1
- **GitHub CLI**: https://cli.github.com/
- **Jekyll Docs**: https://jekyllrb.com/docs/

---

For complete details, see `RELEASE_GUIDE.md`

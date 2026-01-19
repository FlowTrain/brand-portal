# Ruby & Bundler Quick Reference

A guide to common Ruby tasks and concepts for this project.

## What is Bundler?

Bundler is Ruby's dependency manager. It ensures everyone uses the same gem versions by managing two files:

- **Gemfile** - Lists the gems (packages) your project needs
- **Gemfile.lock** - Locks specific versions of those gems (auto-generated)

## Key Files

- `website/microsite/Gemfile` - Declares dependencies (Jekyll, gems, etc.)
- `website/microsite/Gemfile.lock` - Records exact versions installed

## Common Commands

### Update Dependencies
```bash
bundle update
```
Updates all gems to compatible versions. Regenerates `Gemfile.lock`.

```bash
bundle install
```
Installs gems listed in `Gemfile.lock` (use after pulling code with lock file changes).

### Run Commands with Bundle
```bash
bundle exec jekyll serve
```
Runs a command using the exact gems in `Gemfile.lock`.

## Common Issues & Solutions

### Issue: Marshal Error / Cache Incompatibility
**Symptom:** `marshal data too short (ArgumentError)` when starting Jekyll

**Cause:** Cache files from old gem versions don't work with new versions

**Solution:** Clear the cache
```bash
# In website/microsite directory
Remove-Item -Path ".jekyll-cache" -Recurse -Force
Remove-Item -Path "_site" -Recurse -Force
```

### Issue: Gemfile and Gemfile.lock Mismatch
**Symptom:** Gemfile says Jekyll 4.3 but Gemfile.lock has Jekyll 3.9

**Cause:** Lock file wasn't updated after changing Gemfile

**Solution:** Run `bundle update` to regenerate lock file

## Current Setup

- **Ruby Framework:** Jekyll (static site generator)
- **Jekyll Version:** 4.4.1 (specified as ~> 4.3 in Gemfile)
- **Location:** `website/microsite/`

## Typical Workflow

1. **Make changes to Gemfile** (add/remove gems, update versions)
2. **Run** `bundle update` to update lock file
3. **Run** `bundle install` (if working with team, after pulling changes)
4. **Clear cache** if you see weird errors
5. **Start server** with `./start-jekyll-server.ps1`

## Release & Packaging Pipeline

The brand-portal uses a **Makefile-driven release pipeline** for managing multi-package assets (themes, docs, microsite, motion). Key commands:

### Building & Publishing Releases

```bash
# Prepare assets (copy real files to canonical locations)
make assets

# Build ZIP/7z packages + checksums
make package
make checksums

# Generate release notes (auto-filled with asset filenames)
make notes-template TAG=v1.0.1.1 TITLE="v1.0.1.1 — Corrected Artwork & Assets"

# Verify everything locally (site build, archives, checksums)
make verify

# Publish hotfix release to GitHub
make release TAG=v1.0.1.1 TITLE="v1.0.1.1 — Corrected Artwork & Assets"

# Wire downloads page and open PRs
make update-downloads TAG=v1.0.1.1
make pr-downloads TAG=v1.0.1.1
make pr-microsite TAG=v1.0.1.1
```

### Asset Locations

Place real files here (canonical inputs):
- `branding/exports/banner-dark.png` — final banner (1x)
- `branding/exports/banner-dark@2x.png` — retina banner
- `branding/logo/svg/flowtrain-wordmark.svg` — vector wordmark (outlined paths)

System themes & docs:
- `themes/windows/wallpapers/` → 1920×1080, 2560×1440, 3840×2160 (JPG/PNG)
- `themes/macos/wallpapers/` → 2560×1600, 3456×2234, 5120×2880
- `docs/github/` → README_TEMPLATE.md, CONTRIBUTING.md, CODEOWNERS, .github templates
- `docs/confluence/` → Workshop, ADR, Policy templates + README
- `docs/notion/` → JSON/Markdown exports or README with links

Optional (v1.0.2-rc):
- `motion/` → MP4 loops + PNG fallbacks
- `cursors/windows/` → .cur/.ani files + README

## Notes

- Always commit both `Gemfile` AND `Gemfile.lock` to git
- Never manually edit `Gemfile.lock` - let Bundler manage it
- The `~>` syntax means "compatible version" (e.g., `~> 4.3` allows 4.3.x but not 5.0)

## Project Context

This brand-portal project is part of a larger **release & packaging pipeline** using a robust Makefile. See [Makefile](Makefile) for the end-to-end workflow (assets → packages → checksums → GitHub release).

Key related files:
- `scripts/sync-to-canonical-structure.sh` — Repo restructuring (canonical layout)
- `scripts/bootstrap-assets.ps1` — Creates minimal asset placeholders
- Release process documented in [RELEASE_GUIDE.md](RELEASE_GUIDE.md) and [RELEASE_CHEATSHEET.md](RELEASE_CHEATSHEET.md)

---

*Created: 2026-01-18 | For Jekyll 4.4.1 project | Canonical layout v1.0.1+*

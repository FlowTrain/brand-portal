
#!/usr/bin/env bash
# FlowTrain — Sync repo to canonical layout (safe, idempotent)
# Maps your current folders (as per your screenshot) to:
#   themes/*, cursors/windows, docs/*, motion, website/microsite/*
# Backs up conflicting files to backup_migration/.
set -euo pipefail

DRY=false
if [[ "${1:-}" == "--dry-run" ]]; then DRY=true; fi

root="$(pwd)"
echo "→ Syncing repo at: $root"
backup="$root/backup_migration"
mkdir -p "$backup"

# Helpers ---------------------------------------------------------
move_all_contents() {
  local src="$1"; local dest="$2"; local label="${3:-$src}"
  if [[ -d "$src" ]]; then
    echo "• Merge: $src → $dest"
    $DRY || mkdir -p "$dest"
    shopt -s dotglob nullglob
    for f in "$src"/*; do
      local base="$(basename "$f")"
      if [[ -e "$dest/$base" ]]; then
        echo "  ↷ conflict: moving '$f' → '$backup/${dest#"$root/"}_$base'"
        $DRY || { mkdir -p "$backup"; mv "$f" "$backup/${dest#"$root/"}_$base"; }
      else
        $DRY || mv "$f" "$dest/"
      fi
    done
    shopt -u dotglob nullglob
    # remove src if empty
    if $DRY; then :; else rmdir "$src" 2>/dev/null || true; fi
  else
    echo "• Skip (missing): $label"
  fi
}

copy_if_exists() {
  local src="$1"; local dest="$2"; local name="$3"
  if [[ -f "$src" ]]; then
    echo "• Copy: $name → $dest"
    $DRY || { mkdir -p "$(dirname "$dest")"; cp -f "$src" "$dest"; }
  else
    echo "• Skip (missing): $name"
  fi
}

ensure_dir() { $DRY || mkdir -p "$1"; }

# Create working branch ------------------------------------------
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "→ Creating migration branch 'chore/sync-canonical' (safe if exists)…"
  git checkout -B chore/sync-canonical >/dev/null 2>&1 || true
else
  echo "↷ Not a git repo; continuing without branch."
fi

# 1) Canonical folders -------------------------------------------
ensure_dir themes/windows
ensure_dir themes/macos
ensure_dir cursors/windows
ensure_dir docs/notion
ensure_dir docs/confluence
ensure_dir docs/github
ensure_dir motion
ensure_dir branding/exports
ensure_dir branding/logo/svg

# 2) Map your existing layout → canonical ------------------------
# Your screenshot shows 'system' and 'doc' at top-level.

# System → themes/cursors
move_all_contents "system/windows"      "themes/windows"      "system/windows"
move_all_contents "system/macos"        "themes/macos"        "system/macos"
move_all_contents "system/windows/cursors" "cursors/windows"  "system/windows/cursors"

# Docs → docs/*
move_all_contents "doc/notion"          "docs/notion"         "doc/notion"
move_all_contents "doc/confluence"      "docs/confluence"     "doc/confluence"
move_all_contents "doc/github"          "docs/github"         "doc/github"

# Motion (optional)
move_all_contents "motion"              "motion"              "motion"

# 3) Microsite normalization -------------------------------------
# Prefer website/microsite if present; else, create and move root pages.
site="website/microsite"
if [[ -d "$site" ]]; then
  echo "→ Using existing microsite: $site"
else
  echo "→ Creating microsite at: $site"
  ensure_dir "$site/assets/css"
fi

# Move duplicated pages from repo root into website/microsite if not present
for page in index.md brand-foundations.md motion.md productivity.md training-themes.md downloads.md _config.yml; do
  if [[ -f "$page" && ! -f "$site/$page" ]]; then
    echo "• Move page: $page → $site/$page"
    $DRY || mv "$page" "$site/$page"
  fi
done

# Move CSS (if root assets/css/style.css exists)
if [[ -f "assets/css/style.css" && ! -f "$site/assets/css/style.css" ]]; then
  echo "• Move CSS: assets/css/style.css → $site/assets/css/style.css"
  $DRY || { ensure_dir "$site/assets/css"; mv "assets/css/style.css" "$site/assets/css/style.css"; }
fi

# 4) Banner & wordmark (if you have them; otherwise skip quietly)
copy_if_exists "branding/exports/banner-dark.png"      "$site/assets/banner-dark.png"      "banner-dark.png"
copy_if_exists "branding/exports/banner-dark@2x.png"   "$site/assets/banner-dark@2x.png"   "banner-dark@2x.png"
copy_if_exists "branding/logo/svg/flowtrain-wordmark.svg" "$site/assets/logo.svg"          "wordmark.svg"

# 5) Summarize ----------------------------------------------------
echo "→ Sync complete."
echo "  Canonical roots now:"
echo "   - themes/windows, themes/macos, cursors/windows"
echo "   - docs/notion, docs/confluence, docs/github"
echo "   - motion/"
echo "   - website/microsite/ (Jekyll site)"
echo "   - branding/exports, branding/logo/svg"
echo ""
echo "Next:"
echo "  1) Review backup_migration/ for any conflicted files."
echo "  2) git add -A && git commit -m \"chore: sync to canonical layout\""
echo "  3) Run: make doctor && make package checksums notes-template"

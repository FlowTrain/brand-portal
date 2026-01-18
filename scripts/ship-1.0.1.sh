
#!/usr/bin/env bash
# FlowTrain — 1.0.1 shipping bundle
# Runs: assets → package → checksums → notes-template → verify → release → pr-microsite
# Prints: Release URL + PR URL

set -euo pipefail

# -------- Config (override via env or flags) --------
ORG="${ORG:-FlowTrain}"
REPO="${REPO:-brand-portal}"
TAG="${TAG:-v1.0.1}"
TITLE="${TITLE:-v1.0.1 — Microsite + System Assets}"
NOTES_FILE="${NOTES_FILE:-scripts/release-notes-${TAG}.md}"
SITE_DIR="${SITE_DIR:-website/microsite}"

# -------- Parse flags (optional) --------
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)        ORG="$2"; shift 2 ;;
    --repo)       REPO="$2"; shift 2 ;;
    --tag)        TAG="$2"; shift 2 ;;
    --title)      TITLE="$2"; shift 2 ;;
    --notes-file) NOTES_FILE="$2"; shift 2 ;;
    --dry-run)    DRY_RUN=true; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

# -------- Helpers --------
function need() {
  command -v "$1" >/dev/null 2>&1 || { echo "✗ Missing dependency: $1" >&2; exit 1; }
}

function header() { echo -e "\n=== $* ==="; }

# -------- Preflight --------
header "Preflight checks"
need git
need make
need gh
need zip
need 7z || need 7zz  # some systems provide '7zz'
if ! (cd "$SITE_DIR" && bundle exec jekyll -v >/dev/null 2>&1); then
  echo "✗ Jekyll not found for local build. Install: gem install bundler jekyll" >&2
  exit 1
fi

# Verify we are at repo root
test -f Makefile || { echo "✗ Run this from the repo root (Makefile not found)"; exit 1; }
test -d "$SITE_DIR" || { echo "✗ Microsite dir '$SITE_DIR' missing"; exit 1; }

# Check GH auth
if ! gh auth status >/dev/null 2>&1; then
  echo "✗ GitHub CLI not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Ensure main is up to date (no force)
header "Sync main"
git checkout main
git pull --ff-only

# -------- Run pipeline --------
export ORG REPO TAG TITLE NOTES_FILE SITE_DIR

header "Place microsite assets (banner + SVG wordmark)"
$DRY_RUN || make assets

header "Package bundles + checksums"
$DRY_RUN || make package checksums

header "Generate release notes template"
$DRY_RUN || make notes-template

header "Verify: notes reference all assets, site builds, checksums match, SVG paths"
$DRY_RUN || make verify-release-notes
$DRY_RUN || make verify

header "Publish GitHub Release + upload assets"
$DRY_RUN || make release

header "Open Microsite PR (banner + downloads wired to ${TAG})"
$DRY_RUN || make pr-microsite

# -------- Report URLs --------
header "Release & PR URLs"
REL_URL=""
PR_URL=""

if gh release view "$TAG" --repo "$ORG/$REPO" >/dev/null 2>&1; then
  REL_URL="$(gh release view "$TAG" --repo "$ORG/$REPO" --json url --jq .url || true)"
fi

# Try to infer PR URL from branch name used by pr-microsite
PR_URL="$(gh pr list --repo "$ORG/$REPO" --state open --search "microsite $TAG" --json url --jq '.[0].url' || true)"
if [[ -z "$PR_URL" ]]; then
  # Fallback: show most recent open PR
  PR_URL="$(gh pr list --repo "$ORG/$REPO" --state open --json url --jq '.[0].url' || true)"
fi

echo "Release: ${REL_URL:-'(not found yet)'}"
echo "Microsite PR: ${PR_URL:-'(not found yet)'}"

echo -e "\n✅ Done. If everything looks good, merge the PR and share the Release."

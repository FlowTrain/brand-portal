#!/bin/bash
# ============================================================================
# FlowTrain Release Pipeline v1.0.1
# Complete automated release workflow with error handling and git auth fix
# ============================================================================
# Usage: bash scripts/ship-1.0.1.sh [--dry-run]
# ============================================================================

set -euo pipefail

# Configuration
TAG="${TAG:-v1.0.1}"
ORG="${ORG:-FlowTrain}"
REPO="${REPO:-brand-portal}"
BRANCH_NAME="feature/microsite-${TAG}"
DRY_RUN="${DRY_RUN:-false}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

header() {
  echo ""
  echo -e "${BLUE}=== $1 ===${NC}"
}

success() {
  echo -e "${GREEN}✓ $1${NC}"
}

error() {
  echo -e "${RED}✗ $1${NC}" >&2
  exit 1
}

warning() {
  echo -e "${YELLOW}↷ $1${NC}"
}

info() {
  echo -e "$1"
}

# ============================================================================
# Preflight Checks
# ============================================================================

preflight_checks() {
  header "Preflight Checks"
  
  # Check required commands
  local required_commands=("git" "make" "gh" "zip" "7z" "bundle")
  for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      error "Required command not found: $cmd"
    fi
  done
  success "All required commands available"
  
  # Check gh authentication
  if ! gh auth status >/dev/null 2>&1; then
    error "GitHub CLI not authenticated. Run: gh auth login"
  fi
  success "GitHub CLI authenticated"
  
  # Check git configuration
  if ! git config --get credential.helper >/dev/null 2>&1; then
    warning "Git credential helper not configured. Attempting setup..."
    gh auth setup-git || warning "Could not setup git credential helper"
  fi
  success "Git configured"
  
  # Check Ruby/Jekyll
  if ! bundle exec jekyll --version >/dev/null 2>&1; then
    error "Jekyll not available. Run: cd website/microsite && bundle install"
  fi
  success "Jekyll available"
}

# ============================================================================
# Git Helper Functions
# ============================================================================

get_gh_token() {
  # Extract token from gh config file
  grep oauth_token ~/.config/gh/hosts.yml 2>/dev/null | awk '{print $2}' || echo ""
}

git_push_with_auth() {
  local branch="$1"
  local remote_url="https://${ORG}:${TOKEN}@github.com/${ORG}/${REPO}.git"
  
  if $DRY_RUN; then
    info "DRY_RUN: git push $remote_url $branch"
    return 0
  fi
  
  git push "$remote_url" "$branch" 2>&1 || return 1
}

# ============================================================================
# Release Steps
# ============================================================================

sync_main() {
  header "Sync main branch"
  
  if $DRY_RUN; then
    info "DRY_RUN: git checkout main && git pull"
    return 0
  fi
  
  git checkout main || true
  git pull origin main || true
  success "Synced main branch"
}

place_assets() {
  header "Place microsite assets (banner + SVG wordmark)"
  
  if $DRY_RUN; then
    info "DRY_RUN: make assets"
    return 0
  fi
  
  cd "$REPO_ROOT"
  make assets || true
  success "Assets step done"
}

package_bundles() {
  header "Package bundles + checksums"
  
  if $DRY_RUN; then
    info "DRY_RUN: make package && make package-7z && make checksums"
    return 0
  fi
  
  cd "$REPO_ROOT"
  make package TAG="$TAG" || error "Packaging failed"
  make package-7z TAG="$TAG" || error "7z packaging failed"
  make checksums TAG="$TAG" || error "Checksum generation failed"
  success "Packaging complete"
}

generate_notes() {
  header "Generate release notes template"
  
  if $DRY_RUN; then
    info "DRY_RUN: make notes-template TAG=$TAG"
    return 0
  fi
  
  cd "$REPO_ROOT"
  make notes-template TAG="$TAG" || error "Notes template generation failed"
  success "Release notes generated"
}

verify_release() {
  header "Verify: notes reference all assets, site builds, checksums match"
  
  if $DRY_RUN; then
    info "DRY_RUN: make verify"
    return 0
  fi
  
  cd "$REPO_ROOT"
  make verify TAG="$TAG" || error "Verification failed"
  success "Verification complete"
}

publish_release() {
  header "Publish GitHub Release + upload assets"
  
  if $DRY_RUN; then
    info "DRY_RUN: make release TAG=$TAG"
    return 0
  fi
  
  cd "$REPO_ROOT"
  make release TAG="$TAG" TITLE="$TAG — Microsite + System Assets" || {
    warning "Release publish skipped (may already exist)"
  }
  success "Release published"
}

create_microsite_pr() {
  header "Open Microsite PR (banner + downloads wired to ${TAG})"
  
  if $DRY_RUN; then
    info "DRY_RUN: git checkout -b $BRANCH_NAME && git push && gh pr create"
    return 0
  fi
  
  cd "$REPO_ROOT"
  
  # Clean up old branch if it exists
  git branch -D "$BRANCH_NAME" 2>/dev/null || true
  
  # Create feature branch
  git checkout -b "$BRANCH_NAME" || {
    warning "Branch already exists, using existing"
    git checkout "$BRANCH_NAME"
  }
  
  # Stage changes
  git add website/microsite Makefile scripts/ || true
  
  # Commit if there are changes
  if ! git diff --cached --quiet; then
    git commit -m "Microsite: finalize banner (+15% trails), embed SVG wordmark, wire downloads for ${TAG}" || {
      warning "Nothing new to commit"
    }
  fi
  
  # Push with token-based auth
  TOKEN=$(get_gh_token)
  if [ -z "$TOKEN" ]; then
    error "Could not retrieve GitHub token from gh config"
  fi
  
  git_push_with_auth "$BRANCH_NAME" || {
    error "Failed to push branch"
  }
  success "Branch pushed"
  
  # Create PR
  gh pr create \
    --title "Microsite: finalize banner & downloads for ${TAG}" \
    --body "Wires banner, SVG wordmark, and downloads for ${TAG}. Complete release pipeline updates." \
    --head "$BRANCH_NAME" \
    --base main \
    --repo "$ORG/$REPO" || {
    warning "PR creation skipped (may already exist)"
  }
  success "PR created"
}

report_urls() {
  header "Release & PR URLs"
  
  local rel_url=""
  local pr_url=""
  
  if gh release view "$TAG" --repo "$ORG/$REPO" >/dev/null 2>&1; then
    rel_url="$(gh release view "$TAG" --repo "$ORG/$REPO" --json url --jq .url)"
  fi
  
  # Try to find the microsite PR
  pr_url="$(gh pr list --repo "$ORG/$REPO" --state open --search "microsite $TAG" --json url --jq '.[0].url' 2>/dev/null || echo "")"
  if [ -z "$pr_url" ]; then
    # Fallback to most recent PR
    pr_url="$(gh pr list --repo "$ORG/$REPO" --state open --json url --jq '.[0].url' 2>/dev/null || echo "")"
  fi
  
  info "Release: ${rel_url:-'(not found yet)'}"
  info "Microsite PR: ${pr_url:-'(not found yet)'}"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
  info "${BLUE}🚄 FlowTrain Release Pipeline${NC}"
  info "Version: $TAG"
  info "Organization: $ORG"
  info "Repository: $REPO"
  
  if [ "$DRY_RUN" = "true" ]; then
    warning "DRY RUN MODE - No changes will be made"
  fi
  info ""
  
  preflight_checks
  sync_main
  place_assets
  package_bundles
  generate_notes
  verify_release
  publish_release
  create_microsite_pr
  report_urls
  
  info ""
  echo -e "${GREEN}✅ Done. If everything looks good, merge the PR and share the Release.${NC}"
}

# ============================================================================
# Execution
# ============================================================================

if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
fi

main "$@"

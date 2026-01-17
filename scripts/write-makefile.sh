
#!/usr/bin/env bash
set -euo pipefail

# Write Makefile with \t tokens, then convert \t -> real TABs and CRLF -> LF
cat > Makefile.tpl <<'MK'
SHELL := /bin/bash
.DEFAULT_GOAL := help

ORG ?= FlowTrain
REPO ?= brand-portal
MAIN_BRANCH ?= main

TAG ?= v1.0.1
TITLE ?= $(TAG) — Microsite + System Assets
NOTES_FILE ?= scripts/release-notes-$(TAG).md

SITE_DIR ?= website/microsite
ASSETS_DIR ?= $(SITE_DIR)/assets

BANNER_SRC ?= branding/exports/banner-dark.png
BANNER2X_SRC ?= branding/exports/banner-dark@2x.png
WORDMARK_SVG_SRC ?= branding/logo/svg/flowtrain-wordmark.svg

OUT_DIR ?= release/$(TAG)
DIST_DIR ?= dist/$(TAG)
CHECKSUMS ?= $(OUT_DIR)/SHA256SUMS.txt

SHA256 := $(shell command -v sha256sum 2>/dev/null || echo "shasum -a 256")
SEVENZ := $(shell command -v 7z 2>/dev/null || command -v 7zz 2>/dev/null)

PKG_WIN := FlowTrain_Windows_ThemePack
PKG_MAC := FlowTrain_macOS_Wallpapers
PKG_CURSOR := FlowTrain_Cursor_Set
PKG_NOTION := FlowTrain_Notion_Kit
PKG_CONF := FlowTrain_Confluence_Kit
PKG_GITHUB := FlowTrain_GitHub_Kit
PKG_MOTION := FlowTrain_Motion_Assets
PKG_MICRO := FlowTrain_Microsite_Assets

PKGS := $(PKG_WIN) $(PKG_MAC) $(PKG_CURSOR) $(PKG_NOTION) $(PKG_CONF) $(PKG_GITHUB) $(PKG_MOTION) $(PKG_MICRO)
ZIP_FILES := $(addprefix $(OUT_DIR)/,$(addsuffix .zip,$(PKGS)))
SEVENZ_FILES := $(addprefix $(OUT_DIR)/,$(addsuffix .7z,$(PKGS)))

.PHONY: help
help:
\t@echo ""
\t@echo "Flow Train — Make targets"
\t@echo "-------------------------"
\t@echo "make serve                 # Local Jekyll server"
\t@echo "make assets                # Copy banner/logo (if present)"
\t@echo "make package               # Build ZIP + 7z (placeholders if missing)"
\t@echo "make checksums             # SHA-256 file for release"
\t@echo "make notes-template        # Draft release notes w/ assets"
\t@echo "make verify                # Build site + packages + checksums + notes"
\t@echo "make release               # Publish GitHub release with assets + notes"
\t@echo "make update-downloads      # Wire downloads.md to release URLs"
\t@echo "make pr-downloads          # Open PR for downloads update"
\t@echo "make pr-microsite          # Open PR wiring microsite for TAG"
\t@echo "make ship                  # One-shot pipeline"
\t@echo "make promote-rc FROM_TAG=v1.0.2-rc TO_TAG=v1.0.2"
\t@echo "make doctor                # Check required inputs (warns)"
\t@echo "make clean                 # Remove release/dist outputs"
\t@echo ""

.PHONY: serve
serve: | $(ASSETS_DIR)
\tcd $(SITE_DIR) && bundle exec jekyll serve

$(ASSETS_DIR):
\tmkdir -p $(ASSETS_DIR)/logo
\tmkdir -p $(ASSETS_DIR)/css

.PHONY: assets
assets: | $(ASSETS_DIR)
\t@if [ -f "$(BANNER_SRC)" ]; then cp -f "$(BANNER_SRC)" "$(ASSETS_DIR)/banner-dark.png"; else echo "↷ Banner missing $(BANNER_SRC)"; fi
\t@if [ -f "$(BANNER2X_SRC)" ]; then cp -f "$(BANNER2X_SRC)" "$(ASSETS_DIR)/banner-dark@2x.png"; else echo "↷ 2x Banner missing $(BANNER2X_SRC)"; fi
\t@if [ -f "$(WORDMARK_SVG_SRC)" ]; then cp -f "$(WORDMARK_SVG_SRC)" "$(ASSETS_DIR)/logo.svg"; else echo "↷ Wordmark missing $(WORDMARK_SVG_SRC)"; fi
\t@echo "✓ Assets step done."

.PHONY: package
package: prepare-dirs package-zip package-7z
\t@echo "✓ Packaging complete in $(OUT_DIR)"

.PHONY: prepare-dirs
prepare-dirs:
\tmkdir -p "$(OUT_DIR)" "$(DIST_DIR)"

define SAFE_ZIP
\t@if [ -d $(1) ]; then \\
\t  cd $(1) && zip -r "../../$(2)" . ; \\
\telse \\
\t  echo "↷ $(1) missing – creating placeholder $(2)"; \\
\t  echo "$(1) missing $(shell date -Iseconds)" > "$(OUT_DIR)/$(notdir $(2:.zip=.txt))"; \\
\t  (cd $(OUT_DIR) && zip -r "$(notdir $(2))" "$(notdir $(2:.zip=.txt))"); \\
\tfi
endef

$(OUT_DIR)/$(PKG_WIN).zip:    ; $(call SAFE_ZIP,themes/windows,$@)
$(OUT_DIR)/$(PKG_MAC).zip:    ; $(call SAFE_ZIP,themes/macos,$@)
$(OUT_DIR)/$(PKG_CURSOR).zip: ; $(call SAFE_ZIP,cursors/windows,$@)
$(OUT_DIR)/$(PKG_NOTION).zip: ; $(call SAFE_ZIP,docs/notion,$@)
$(OUT_DIR)/$(PKG_CONF).zip:   ; $(call SAFE_ZIP,docs/confluence,$@)
$(OUT_DIR)/$(PKG_GITHUB).zip: ; $(call SAFE_ZIP,docs/github,$@)
$(OUT_DIR)/$(PKG_MOTION).zip: ; $(call SAFE_ZIP,motion,$@)

$(OUT_DIR)/$(PKG_MICRO).zip: assets
\t@echo "→ Zipping microsite from $(SITE_DIR)…"
\t@if [ -f "$(SITE_DIR)/index.md" ]; then \\
\t  (cd $(SITE_DIR) && zip -r "../../$@" assets _config.yml index.md brand-foundations.md motion.md productivity.md training-themes.md downloads.md 2>/dev/null || true); \\
\telse \\
\t  echo "↷ No index.md in $(SITE_DIR); creating placeholder $(notdir $@)"; \\
\t  echo "Microsite placeholder $(shell date -Iseconds)" > "$(OUT_DIR)/$(PKG_MICRO).txt"; \\
\t  (cd $(OUT_DIR) && zip -r "$(PKG_MICRO).zip" "$(PKG_MICRO).txt"); \\
\tfi

package-zip: $(ZIP_FILES)

package-7z:
\t@if [ -n "$(SEVENZ)" ]; then \\
\t  for z in $(ZIP_FILES); do base=$${z%.zip}; (cd $(OUT_DIR) && $(SEVENZ) a -t7z "$${base##*/}.7z" "$${z##*/}" >/dev/null); done; \\
\telse echo "↷ 7z not found; skipping .7z creation."; fi

.PHONY: checksums
checksums: $(ZIP_FILES)
\t@test -n "$(SHA256)" || (echo "✗ sha256sum/shasum missing"; exit 1)
\t@rm -f "$(CHECKSUMS)"
\t@cd "$(OUT_DIR)" && $(SHA256) $(notdir $(ZIP_FILES)) $(wildcard $(notdir $(SEVENZ_FILES))) > $(notdir $(CHECKSUMS))
\t@echo "✓ $(CHECKSUMS)"

.PHONY: notes-template
notes-template: prepare-dirs
\t@mkdir -p $(dir $(NOTES_FILE))
\t@{ \\
\t  echo "# 🚄 FlowTrain $(TAG)"; \\
\t  echo "**Microsite Launch · Brand Assets · System Themes**"; \\
\t  echo ""; \\
\t  echo "**Release Date:** $$(date +%Y-%m-%d)"; \\
\t  echo ""; \\
\t  echo "## ✨ Highlights"; \\
\t  echo "- Microsite (dark mode, SVG wordmark when available)"; \\
\t  echo "- Brand banner (+15% star-trail density)"; \\
\t  echo "- System themes (Windows/macOS) + docs kits (Notion/Confluence/GitHub)"; \\
\t  echo "- Motion assets (if provided)"; \\
\t  echo ""; \\
\t  echo "## 📦 What’s Included"; \\
\t  for f in $(ZIP_FILES); do echo "- $$(basename "$$f")"; done; \\
\t  echo ""; \\
\t  echo "## 🔐 Checksums"; \\
\t  echo "See \`$$(basename $(CHECKSUMS))\` attached."; \\
\t  echo ""; \\
\t  echo "## 🔮 Next (v1.0.2)"; \\
\t  echo "- Fonts aligned to wordmark · Ultrawide banner · Motion refinements"; \\
\t} > "$(NOTES_FILE)"
\t@echo "✓ Notes template created at $(NOTES_FILE)"

.PHONY: verify
verify: verify-site verify-packages verify-checksums verify-release-notes verify-svg
\t@echo "✓ Verification complete."

.PHONY: verify-site
verify-site:
\tcd $(SITE_DIR) && bundle exec jekyll build --trace
\t@echo "✓ Jekyll build completed."

.PHONY: verify-packages
verify-packages:
\t@for f in $(ZIP_FILES); do test -f $$f || (echo "✗ Missing $$f"; exit 1); done
\t@if [ -n "$(SEVENZ)" ]; then for f in $(SEVENZ_FILES); do test -f $$f || (echo "✗ Missing $$f"; exit 1); done; \\
\telse echo "↷ 7z not found; skipping .7z checks."; fi
\t@echo "✓ Package archives present."

.PHONY: verify-checksums
verify-checksums:
\t@test -f "$(CHECKSUMS)" || (echo "✗ Missing $(CHECKSUMS). Run: make checksums"; exit 1)
\t@cd $(OUT_DIR) && ($(SHA256) $(notdir $(ZIP_FILES)) $(wildcard $(notdir $(SEVENZ_FILES))) > SHA256SUMS.recalc.txt) && diff -q SHA256SUMS.recalc.txt $(notdir $(CHECKSUMS)) || (echo "✗ Checksum mismatch"; exit 1)
\t@echo "✓ Checksums verified."

.PHONY: verify-release-notes
verify-release-notes:
\t@test -f "$(NOTES_FILE)" || (echo "✗ Missing $(NOTES_FILE). Run: make notes-template"; exit 1)
\t@missing=0; \\
\tfor f in $(ZIP_FILES) $(wildcard $(SEVENZ_FILES)) $(CHECKSUMS); do \\
\t  name=$$(basename "$$f"); grep -Fq "$$name" "$(NOTES_FILE)" || { echo "✗ Notes missing: $$name"; missing=1; }; \\
\tdone; \\
\t[ $$missing -eq 0 ] || exit 1
\t@echo "✓ Notes mention all assets."

.PHONY: verify-svg
verify-svg:
\t@if [ -f "$(ASSETS_DIR)/logo.svg" ]; then \\
\t  grep -Eq "<path\\b" "$(ASSETS_DIR)/logo.svg" && echo "✓ SVG wordmark uses paths." || echo "↷ WARNING: logo.svg may not be outlined."; \\
\telse echo "↷ WARNING: $(ASSETS_DIR)/logo.svg missing (ok to proceed)."; fi

DOWNLOADS_MD ?= $(SITE_DIR)/downloads.md

.PHONY: update-downloads
update-downloads:
\t@set -euo pipefail; \\
\tgh auth status >/dev/null || { echo "✗ gh not authenticated. Run: gh auth login"; exit 1; }; \\
\tASSETS="$$(gh release view $(TAG) --repo $(ORG)/$(REPO) --json assets --jq '.assets[].name' 2>/dev/null || true)"; \\
\t[ -n "$$ASSETS" ] || { echo "✗ No assets for $(TAG). Run make release first."; exit 1; }; \\
\tBASE="https://github.com/$(ORG)/$(REPO)/releases/download/$(TAG)"; \\
\tTMP_DIR="$$(mktemp -d)"; BLOCK_FILE="$$TMP_DIR/block.md"; \\
\tCAT_WIN=""; CAT_MAC=""; CAT_CURSOR=""; CAT_DOCS=""; CAT_MOTION=""; CAT_MICRO=""; \\
\twhile IFS= read -r n; do [ -n "$$n" ] || continue; url="$$BASE/$$n"; \\
\t  case "$$n" in \\
\t    FlowTrain_Windows_ThemePack.*) CAT_WIN="$$CAT_WIN\n- $$n";; \\
\t    FlowTrain_macOS_Wallpapers.*)  CAT_MAC="$$CAT_MAC\n- $$n";; \\
\t    FlowTrain_Cursor_Set.*)        CAT_CURSOR="$$CAT_CURSOR\n- $$n";; \\
\t    FlowTrain_Notion_Kit.*|FlowTrain_Confluence_Kit.*|FlowTrain_GitHub_Kit.*) CAT_DOCS="$$CAT_DOCS\n- [$$n;; \\
\t    FlowTrain_Motion_Assets.*)     CAT_MOTION="$$CAT_MOTION\n- [$$n]($$\
\t    *)                             CAT_MICRO="$$CAT_MICRO\n- $$n";; \\
\t  esac; done <<< "$$ASSETS"; \\
\tprintf "%s\n" "<!-- ASSET_LINKS_START -->"        >  "$$BLOCK_FILE"; \\
\tprintf "\n## Downloads ($(TAG))\n\n"              >> "$$BLOCK_FILE"; \\
\tprintf "### System Themes\n%s\n%s\n%s\n\n"        "$$CAT_WIN" "$$CAT_MAC" "$$CAT_CURSOR" >> "$$BLOCK_FILE"; \\
\tprintf "### Documentation Kits\n%s\n\n"           "$$CAT_DOCS"   >> "$$BLOCK_FILE"; \\
\tprintf "### Motion Assets\n%s\n\n"                "$$CAT_MOTION" >> "$$BLOCK_FILE"; \\
\tprintf "### Microsite & Other\n%s\n\n"            "$$CAT_MICRO"  >> "$$BLOCK_FILE"; \\
\tprintf "%s\n" "<!-- ASSET_LINKS_END -->"          >> "$$BLOCK_FILE"; \\
\tif grep -q "<!-- ASSET_LINKS_START -->" "$(DOWNLOADS_MD)"; then \\
\t  awk -v blk="$$BLOCK_FILE" 'BEGIN{while((getline l<blk)>0) b=b l "\\n"} \\
\t    /<!-- ASSET_LINKS_START -->/{print b; skip=1; next} \\
\t    skip && /<!-- ASSET_LINKS_END -->/{skip=0; next} \\
\t    skip{next} {print}' "$(DOWNLOADS_MD)" > "$$TMP_DIR/updated.md"; \\
\t  cp "$$TMP_DIR/updated.md" "$(DOWNLOADS_MD)"; \\
\telse \\
\t  cat "$(DOWNLOADS_MD)" "$$BLOCK_FILE" > "$$TMP_DIR/updated.md"; \\
\t  cp "$$TMP_DIR/updated.md" "$(DOWNLOADS_MD)"; \\
\tfi; rm -rf "$$TMP_DIR"; echo "✓ downloads.md updated."

.PHONY: pr-downloads
pr-downloads:
\tgh auth status >/dev/null || (echo "✗ gh not authenticated"; exit 1)
\tgit checkout -b chore/downloads-$(TAG) || true
\tgit add $(DOWNLOADS_MD) || true
\tgit commit -m "docs(downloads): wire asset links for $(TAG)" || true
\tgit push -u origin chore/downloads-$(TAG) || true
\tgh pr create --title "docs: update downloads to $(TAG)" --body "Auto-wired downloads.md to $(TAG)." --repo $(ORG)/$(REPO) || true

.PHONY: pr-microsite
pr-microsite:
\tgit checkout -b feature/microsite-$(TAG) || true
\tgit add $(SITE_DIR) || true
\tgit commit -m "Microsite: finalize banner (+15% trails), embed SVG wordmark, wire downloads for $(TAG)" || true
\tgit push -u origin feature/microsite-$(TAG) || true
\tgh pr create --title "Microsite: finalize banner & downloads for $(TAG)" --body "Wires banner, SVG wordmark, and downloads for $(TAG)." --repo $(ORG)/$(REPO) || true

.PHONY: ship
ship: assets package checksums notes-template verify release pr-microsite
\t@echo "🚄 FlowTrain $(TAG) shipped."

.PHONY: promote-rc
promote-rc: _check-promote-vars
\t@set -euo pipefail; \\
\tFROM="$(FROM_TAG)"; TO="$(TO_TAG)"; OUT="release/$$FROM"; \\
\tgh auth status >/dev/null || { echo "✗ gh not authenticated"; exit 1; }; \\
\tgh release view "$$FROM" --repo "$(ORG)/$(REPO)" >/dev/null || { echo "✗ RC $$FROM not found"; exit 1; }; \\
\tmkdir -p "$$OUT"; gh release download "$$FROM" --dir "$$OUT" --repo "$(ORG)/$(REPO)" --clobber >/dev/null; \\
\tif [ -n "$(NOTES_FILE)" ] && [ -f "$(NOTES_FILE)" ]; then \\
\t  gh release create "$$TO" "$$OUT"/* --repo "$(ORG)/$(REPO)" --title "$(TITLE)" --notes-file "$(NOTES_FILE)"; \\
\telse \\
\t  TMP="$$(mktemp)"; echo "# $$TO — Promoted from $$FROM" > "$$TMP"; \\
\t  gh release create "$$TO" "$$OUT"/* --repo "$(ORG)/$(REPO)" --title "$(TITLE)" --notes-file "$$TMP"; \\
\tfi; gh release view "$$TO" --repo "$(ORG)/$(REPO)"

.PHONY: _check-promote-vars
_check-promote-vars:
\t@test -n "$(FROM_TAG)" || (echo "✗ FROM_TAG required"; exit 1)
\t@test -n "$(TO_TAG)"   || (echo "✗ TO_TAG required"; exit 1)

.PHONY: doctor
doctor:
\t@echo "SITE_DIR=$(SITE_DIR)"; \
\t[ -f "$(SITE_DIR)/_config.yml" ] || echo "↷ WARNING: $(SITE_DIR)/_config.yml missing"; \
\t[ -f "$(SITE_DIR)/index.md" ] || echo "↷ WARNING: $(SITE_DIR)/index.md missing"; \
\t[ -f "$(ASSETS_DIR)/css/style.css" ] || echo "↷ WARNING: $(ASSETS_DIR)/css/style.css missing"; \
\t[ -d themes/windows ] || echo "↷ WARNING: themes/windows missing"; \
\t[ -d themes/macos ] || echo "↷ WARNING: themes/macos missing"; \
\t[ -d cursors/windows ] || echo "↷ WARNING: cursors/windows missing"; \
\t[ -d docs/notion ] || echo "↷ WARNING: docs/notion missing"; \
\t[ -d docs/confluence ] || echo "↷ WARNING: docs/confluence missing"; \
\t[ -d docs/github ] || echo "↷ WARNING: docs/github missing"; \
\t[ -d motion ] || echo "↷ WARNING: motion missing"; \
\t[ -f "$(ASSETS_DIR)/banner-dark.png" ] || echo "↷ WARNING: banner-dark.png missing"; \
\t[ -f "$(ASSETS_DIR)/logo.svg" ] || echo "↷ WARNING: logo.svg missing"

.PHONY: clean
clean:
\trm -rf "$(OUT_DIR)" "$(DIST_DIR)"
\t@echo "✓ Cleaned."
MK

# Replace \t with real tabs; convert \\ to \ for line continuations; strip CR if any
sed -e 's/\\t/\t/g' -e 's/\\\\/\\/g' -e 's/\r$//' Makefile.tpl > Makefile
rm -f Makefile.tpl
echo "✓ Makefile written with real TABs and LF endings."

chmod +x scripts/write-makefile.sh

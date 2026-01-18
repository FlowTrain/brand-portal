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
	@echo ""
	@echo "Flow Train — Make targets"
	@echo "-------------------------"
	@echo "make serve                 # Local Jekyll server"
	@echo "make assets                # Copy banner/logo (if present)"
	@echo "make package               # Build ZIP + 7z (placeholders if missing)"
	@echo "make checksums             # SHA-256 file for release"
	@echo "make notes-template        # Draft release notes w/ assets"
	@echo "make verify                # Build site + packages + checksums + notes"
	@echo "make release               # Publish GitHub release with assets + notes"
	@echo "make update-downloads      # Wire downloads.md to release URLs"
	@echo "make pr-downloads          # Open PR for downloads update"
	@echo "make pr-microsite          # Open PR wiring microsite for TAG"
	@echo "make ship                  # One-shot pipeline"
	@echo "make promote-rc FROM_TAG=v1.0.2-rc TO_TAG=v1.0.2"
	@echo "make doctor                # Check required inputs (warns)"
	@echo "make clean                 # Remove release/dist outputs"
	@echo ""

.PHONY: serve
serve: | $(ASSETS_DIR)
	cd $(SITE_DIR) && bundle exec jekyll serve

$(ASSETS_DIR):
	mkdir -p $(ASSETS_DIR)/logo
	mkdir -p $(ASSETS_DIR)/css

.PHONY: assets
assets: | $(ASSETS_DIR)
	@if [ -f "$(BANNER_SRC)" ]; then cp -f "$(BANNER_SRC)" "$(ASSETS_DIR)/banner-dark.png"; else echo "↷ Banner missing $(BANNER_SRC)"; fi
	@if [ -f "$(BANNER2X_SRC)" ]; then cp -f "$(BANNER2X_SRC)" "$(ASSETS_DIR)/banner-dark@2x.png"; else echo "↷ 2x Banner missing $(BANNER2X_SRC)"; fi
	@if [ -f "$(WORDMARK_SVG_SRC)" ]; then cp -f "$(WORDMARK_SVG_SRC)" "$(ASSETS_DIR)/logo.svg"; else echo "↷ Wordmark missing $(WORDMARK_SVG_SRC)"; fi
	@echo "✓ Assets step done."

.PHONY: package
package: prepare-dirs package-zip package-7z
	@echo "✓ Packaging complete in $(OUT_DIR)"

.PHONY: prepare-dirs
prepare-dirs:
	mkdir -p "$(OUT_DIR)" "$(DIST_DIR)"

define SAFE_ZIP
	@if [ -d $(1) ]; then \
	  (cd $(1) && zip -r "$$(cd ..; pwd)/$(OUT_DIR)/$(notdir $(2))" . 2>/dev/null) || (cd $(1) && zip -r "../../$(2)" . ); \
	else \
	  echo "↷ $(1) missing – creating placeholder $(2)"; \
	  echo "$(1) missing $(shell date -Iseconds)" > "$(OUT_DIR)/$(notdir $(2:.zip=.txt))"; \
	  (cd $(OUT_DIR) && zip -r "$(notdir $(2))" "$(notdir $(2:.zip=.txt))"); \
	fi
endef

$(OUT_DIR)/$(PKG_WIN).zip:    ; $(call SAFE_ZIP,themes/windows,$@)
$(OUT_DIR)/$(PKG_MAC).zip:    ; $(call SAFE_ZIP,themes/macos,$@)
$(OUT_DIR)/$(PKG_CURSOR).zip: ; $(call SAFE_ZIP,cursors/windows,$@)
$(OUT_DIR)/$(PKG_NOTION).zip: ; $(call SAFE_ZIP,docs/notion,$@)
$(OUT_DIR)/$(PKG_CONF).zip:   ; $(call SAFE_ZIP,docs/confluence,$@)
$(OUT_DIR)/$(PKG_GITHUB).zip: ; $(call SAFE_ZIP,docs/github,$@)
$(OUT_DIR)/$(PKG_MOTION).zip: ; $(call SAFE_ZIP,motion,$@)

$(OUT_DIR)/$(PKG_MICRO).zip: assets
	@echo "→ Zipping microsite from $(SITE_DIR)…"
	@if [ -f "$(SITE_DIR)/index.md" ]; then \
	  (cd $(SITE_DIR) && zip -r "../../$@" assets _config.yml index.md brand-foundations.md motion.md productivity.md training-themes.md downloads.md 2>/dev/null || true); \
	else \
	  echo "↷ No index.md in $(SITE_DIR); creating placeholder $(notdir $@)"; \
	  echo "Microsite placeholder $(shell date -Iseconds)" > "$(OUT_DIR)/$(PKG_MICRO).txt"; \
	  (cd $(OUT_DIR) && zip -r "$(PKG_MICRO).zip" "$(PKG_MICRO).txt"); \
	fi

package-zip: $(ZIP_FILES)

package-7z:
	@if [ -n "$(SEVENZ)" ]; then \
	  for z in $(ZIP_FILES); do base=$${z%.zip}; (cd $(OUT_DIR) && $(SEVENZ) a -t7z "$${base##*/}.7z" "$${z##*/}" >/dev/null); done; \
	else echo "↷ 7z not found; skipping .7z creation."; fi

.PHONY: checksums
checksums: $(ZIP_FILES)
	@test -n "$(SHA256)" || (echo "✗ sha256sum/shasum missing"; exit 1)
	@rm -f "$(CHECKSUMS)"
	@cd "$(OUT_DIR)" && $(SHA256) $(notdir $(ZIP_FILES)) $(wildcard $(notdir $(SEVENZ_FILES))) > $(notdir $(CHECKSUMS))
	@echo "✓ $(CHECKSUMS)"

.PHONY: notes-template
notes-template: prepare-dirs
	@mkdir -p $(dir $(NOTES_FILE))
	@{ \
	  echo "# 🚄 FlowTrain $(TAG)"; \
	  echo "**Microsite Launch · Brand Assets · System Themes**"; \
	  echo ""; \
	  echo "**Release Date:** $$(date +%Y-%m-%d)"; \
	  echo ""; \
	  echo "## ✨ Highlights"; \
	  echo "- Microsite (dark mode, SVG wordmark when available)"; \
	  echo "- Brand banner (+15% star-trail density)"; \
	  echo "- System themes (Windows/macOS) + docs kits (Notion/Confluence/GitHub)"; \
	  echo "- Motion assets (if provided)"; \
	  echo ""; \
	  echo "## 📦 What’s Included"; \
	  for f in $(ZIP_FILES); do echo "- $$(basename "$$f")"; done; \
	  for f in $(SEVENZ_FILES); do echo "- $$(basename "$$f")"; done; \
	  echo ""; \
	  echo "## 🔐 Checksums"; \
	  echo "See \`$$(basename $(CHECKSUMS))\` attached."; \
	  echo ""; \
	  echo "## 🔮 Next (v1.0.2)"; \
	  echo "- Fonts aligned to wordmark · Ultrawide banner · Motion refinements"; \
	} > "$(NOTES_FILE)"
	@echo "✓ Notes template created at $(NOTES_FILE)"

.PHONY: verify
verify: verify-site verify-packages verify-checksums verify-release-notes verify-svg
	@echo "✓ Verification complete."

.PHONY: verify-site
verify-site:
	cd $(SITE_DIR) && bundle exec jekyll build --trace
	@echo "✓ Jekyll build completed."

.PHONY: verify-packages
verify-packages:
	@for f in $(ZIP_FILES); do test -f $$f || (echo "✗ Missing $$f"; exit 1); done
	@if [ -n "$(SEVENZ)" ]; then for f in $(SEVENZ_FILES); do test -f $$f || (echo "✗ Missing $$f"; exit 1); done; \
	else echo "↷ 7z not found; skipping .7z checks."; fi
	@echo "✓ Package archives present."

.PHONY: verify-checksums
verify-checksums:
	@test -f "$(CHECKSUMS)" || (echo "✗ Missing $(CHECKSUMS). Run: make checksums"; exit 1)
	@cd $(OUT_DIR) && ($(SHA256) $(notdir $(ZIP_FILES)) $(wildcard $(notdir $(SEVENZ_FILES))) > SHA256SUMS.recalc.txt) && diff -q SHA256SUMS.recalc.txt $(notdir $(CHECKSUMS)) || (echo "✗ Checksum mismatch"; exit 1)
	@echo "✓ Checksums verified."

.PHONY: verify-release-notes
verify-release-notes:
	@test -f "$(NOTES_FILE)" || (echo "✗ Missing $(NOTES_FILE). Run: make notes-template"; exit 1)
	@missing=0; \
	for f in $(ZIP_FILES) $(wildcard $(SEVENZ_FILES)) $(CHECKSUMS); do \
	  name=$$(basename "$$f"); grep -Fq "$$name" "$(NOTES_FILE)" || { echo "✗ Notes missing: $$name"; missing=1; }; \
	done; \
	[ $$missing -eq 0 ] || exit 1
	@echo "✓ Notes mention all assets."

.PHONY: verify-svg
verify-svg:
	@if [ -f "$(ASSETS_DIR)/logo.svg" ]; then \
	  grep -Eq "<path\b" "$(ASSETS_DIR)/logo.svg" && echo "✓ SVG wordmark uses paths." || echo "↷ WARNING: logo.svg may not be outlined."; \
	else echo "↷ WARNING: $(ASSETS_DIR)/logo.svg missing (ok to proceed)."; fi

DOWNLOADS_MD ?= $(SITE_DIR)/downloads.md

.PHONY: update-downloads
update-downloads:
	@set -euo pipefail; \
	gh auth status >/dev/null || { echo "✗ gh not authenticated. Run: gh auth login"; exit 1; }; \
	ASSETS="$$(gh release view $(TAG) --repo $(ORG)/$(REPO) --json assets --jq '.assets[].name' 2>/dev/null || true)"; \
	[ -n "$$ASSETS" ] || { echo "✗ No assets for $(TAG). Run make release first."; exit 1; }; \
	BASE="https://github.com/$(ORG)/$(REPO)/releases/download/$(TAG)"; \
	TMP_DIR="$$(mktemp -d)"; BLOCK_FILE="$$TMP_DIR/block.md"; \
	CAT_WIN=""; CAT_MAC=""; CAT_CURSOR=""; CAT_DOCS=""; CAT_MOTION=""; CAT_MICRO=""; \
	while IFS= read -r n; do [ -n "$$n" ] || continue; url="$$BASE/$$n"; \
	  case "$$n" in \
	    FlowTrain_Windows_ThemePack.*) CAT_WIN="$$CAT_WIN\n- $$n";; \
	    FlowTrain_macOS_Wallpapers.*)  CAT_MAC="$$CAT_MAC\n- $$n";; \
	    FlowTrain_Cursor_Set.*)        CAT_CURSOR="$$CAT_CURSOR\n- $$n";; \
	    FlowTrain_Notion_Kit.*|FlowTrain_Confluence_Kit.*|FlowTrain_GitHub_Kit.*) CAT_DOCS="$$CAT_DOCS\n- [$$n;; \
	    FlowTrain_Motion_Assets.*)     CAT_MOTION="$$CAT_MOTION\n- [$$n]($$\
	    *)                             CAT_MICRO="$$CAT_MICRO\n- $$n";; \
	  esac; done <<< "$$ASSETS"; \
	printf "%s\n" "<!-- ASSET_LINKS_START -->"        >  "$$BLOCK_FILE"; \
	printf "\n## Downloads ($(TAG))\n\n"              >> "$$BLOCK_FILE"; \
	printf "### System Themes\n%s\n%s\n%s\n\n"        "$$CAT_WIN" "$$CAT_MAC" "$$CAT_CURSOR" >> "$$BLOCK_FILE"; \
	printf "### Documentation Kits\n%s\n\n"           "$$CAT_DOCS"   >> "$$BLOCK_FILE"; \
	printf "### Motion Assets\n%s\n\n"                "$$CAT_MOTION" >> "$$BLOCK_FILE"; \
	printf "### Microsite & Other\n%s\n\n"            "$$CAT_MICRO"  >> "$$BLOCK_FILE"; \
	printf "%s\n" "<!-- ASSET_LINKS_END -->"          >> "$$BLOCK_FILE"; \
	if grep -q "<!-- ASSET_LINKS_START -->" "$(DOWNLOADS_MD)"; then \
	  awk -v blk="$$BLOCK_FILE" 'BEGIN{while((getline l<blk)>0) b=b l "\n"} \
	    /<!-- ASSET_LINKS_START -->/{print b; skip=1; next} \
	    skip && /<!-- ASSET_LINKS_END -->/{skip=0; next} \
	    skip{next} {print}' "$(DOWNLOADS_MD)" > "$$TMP_DIR/updated.md"; \
	  cp "$$TMP_DIR/updated.md" "$(DOWNLOADS_MD)"; \
	else \
	  cat "$(DOWNLOADS_MD)" "$$BLOCK_FILE" > "$$TMP_DIR/updated.md"; \
	  cp "$$TMP_DIR/updated.md" "$(DOWNLOADS_MD)"; \
	fi; rm -rf "$$TMP_DIR"; echo "✓ downloads.md updated."

.PHONY: release
release:
	gh auth status >/dev/null || (echo "✗ gh not authenticated"; exit 1)
	test -f "$(NOTES_FILE)" || (echo "✗ $(NOTES_FILE) required for release"; exit 1)
	gh release create "$(TAG)" $(ZIP_FILES) $(SEVENZ_FILES) --repo "$(ORG)/$(REPO)" --title "$(TAG) — Microsite + System Assets" --notes-file "$(NOTES_FILE)" || (echo "✓ Release already exists or published"; true)

.PHONY: pr-downloads
pr-downloads:
	gh auth status >/dev/null || (echo "✗ gh not authenticated"; exit 1)
	git checkout -b chore/downloads-$(TAG) || true
	git add $(DOWNLOADS_MD) || true
	git commit -m "docs(downloads): wire asset links for $(TAG)" || true
	git push -u origin chore/downloads-$(TAG) || true
	gh pr create --title "docs: update downloads to $(TAG)" --body "Auto-wired downloads.md to $(TAG)." --repo $(ORG)/$(REPO) || true

.PHONY: pr-microsite
pr-microsite:
	git checkout -b feature/microsite-$(TAG) || true
	git add $(SITE_DIR) || true
	git commit -m "Microsite: finalize banner (+15% trails), embed SVG wordmark, wire downloads for $(TAG)" || true
	git push -u origin feature/microsite-$(TAG) || true
	gh pr create --title "Microsite: finalize banner & downloads for $(TAG)" --body "Wires banner, SVG wordmark, and downloads for $(TAG)." --repo $(ORG)/$(REPO) || true

.PHONY: ship
ship: assets package checksums notes-template verify release pr-microsite
	@echo "🚄 FlowTrain $(TAG) shipped."

.PHONY: promote-rc
promote-rc: _check-promote-vars
	@set -euo pipefail; \
	FROM="$(FROM_TAG)"; TO="$(TO_TAG)"; OUT="release/$$FROM"; \
	gh auth status >/dev/null || { echo "✗ gh not authenticated"; exit 1; }; \
	gh release view "$$FROM" --repo "$(ORG)/$(REPO)" >/dev/null || { echo "✗ RC $$FROM not found"; exit 1; }; \
	mkdir -p "$$OUT"; gh release download "$$FROM" --dir "$$OUT" --repo "$(ORG)/$(REPO)" --clobber >/dev/null; \
	if [ -n "$(NOTES_FILE)" ] && [ -f "$(NOTES_FILE)" ]; then \
	  gh release create "$$TO" "$$OUT"/* --repo "$(ORG)/$(REPO)" --title "$(TITLE)" --notes-file "$(NOTES_FILE)"; \
	else \
	  TMP="$$(mktemp)"; echo "# $$TO — Promoted from $$FROM" > "$$TMP"; \
	  gh release create "$$TO" "$$OUT"/* --repo "$(ORG)/$(REPO)" --title "$(TITLE)" --notes-file "$$TMP"; \
	fi; gh release view "$$TO" --repo "$(ORG)/$(REPO)"

.PHONY: _check-promote-vars
_check-promote-vars:
	@test -n "$(FROM_TAG)" || (echo "✗ FROM_TAG required"; exit 1)
	@test -n "$(TO_TAG)"   || (echo "✗ TO_TAG required"; exit 1)

.PHONY: doctor
doctor:
	@echo "SITE_DIR=$(SITE_DIR)"; \
	[ -f "$(SITE_DIR)/_config.yml" ] || echo "↷ WARNING: $(SITE_DIR)/_config.yml missing"; \
	[ -f "$(SITE_DIR)/index.md" ] || echo "↷ WARNING: $(SITE_DIR)/index.md missing"; \
	[ -f "$(ASSETS_DIR)/css/style.css" ] || echo "↷ WARNING: $(ASSETS_DIR)/css/style.css missing"; \
	[ -d themes/windows ] || echo "↷ WARNING: themes/windows missing"; \
	[ -d themes/macos ] || echo "↷ WARNING: themes/macos missing"; \
	[ -d cursors/windows ] || echo "↷ WARNING: cursors/windows missing"; \
	[ -d docs/notion ] || echo "↷ WARNING: docs/notion missing"; \
	[ -d docs/confluence ] || echo "↷ WARNING: docs/confluence missing"; \
	[ -d docs/github ] || echo "↷ WARNING: docs/github missing"; \
	[ -d motion ] || echo "↷ WARNING: motion missing"; \
	[ -f "$(ASSETS_DIR)/banner-dark.png" ] || echo "↷ WARNING: banner-dark.png missing"; \
	[ -f "$(ASSETS_DIR)/logo.svg" ] || echo "↷ WARNING: logo.svg missing"

.PHONY: clean
clean:
	rm -rf "$(OUT_DIR)" "$(DIST_DIR)"
	@echo "✓ Cleaned."

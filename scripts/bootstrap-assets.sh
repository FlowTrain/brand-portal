
#!/usr/bin/env bash
set -euo pipefail

mk() { mkdir -p "$1"; }

# 1) Canonical dirs
for d in \
  website/microsite/assets/css branding/exports branding/logo/svg \
  themes/windows themes/macos cursors/windows docs/notion docs/confluence docs/github motion \
  scripts release dist
do mk "$d"; done

# 2) Minimal CSS
css=website/microsite/assets/css/style.css
if [ ! -f "$css" ]; then
cat > "$css" <<'CSS'
:root{color-scheme:dark}
body{margin:0;font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Arial;background:#0b121a;color:#dbe6ff}
.banner{height:300px;background:linear-gradient(180deg,#0b121a,#0e1622);display:flex;align-items:center;justify-content:center}
.banner img{max-height:140px;filter:drop-shadow(0 0 18px rgba(43,174,228,.35)) drop-shadow(0 0 4px rgba(90,79,207,.25))}
h1,h2,h3{color:#e7f0ff} a{color:#7dd3fc}
CSS
fi

# 3) Placeholder SVG wordmark
logo=website/microsite/assets/logo.svg
if [ ! -f "$logo" ]; then
cat > "$logo" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 300">
  <defs><linearGradient id="g" x1="0" x2="1"><stop offset="20%" stop-color="#5155a5"/><stop offset="100%" stop-color="#00b0f0"/></linearGradient></defs>
  <rect width="1200" height="300" fill="none"/>
  <text x="50%" y="55%" dominant-baseline="middle" text-anchor="middle"
        fill="url(#g)" font-family="Segoe UI, Roboto, Arial" font-size="120" letter-spacing="2">FlowTrain</text>
</svg>
SVG
fi

# 4) 1x1 PNG placeholders (dark)
png_b64='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/w8AAgMBg3h0x4UAAAAASUVORK5CYII='
echo "$png_b64" | base64 -d > website/microsite/assets/banner-dark.png
echo "$png_b64" | base64 -d > website/microsite/assets/banner-dark@2x.png

# 5) Package placeholders
declare -A files=(
  [themes/windows/README.txt]="Windows Theme Pack placeholder"
  [themes/macos/README.txt]="macOS Wallpapers placeholder"
  [cursors/windows/README.txt]="Cursor Set placeholder"
  [docs/notion/README.md]="# Notion Kit placeholder"
  [docs/confluence/README.md]="# Confluence Kit placeholder"
  [docs/github/README.md]="# GitHub Kit placeholder"
  [motion/README.md]="# Motion assets placeholder"
)
for f in "${!files[@]}"; do
  [ -f "$f" ] || echo "${files[$f]}" > "$f"
done

echo "✓ Bootstrap complete."
echo "Next:"
echo "  make package checksums notes-template verify"
echo "  make release TAG=v1.0.1 TITLE='v1.0.1 — Microsite + System Assets'"
echo "  make update-downloads TAG=v1.0.1 && make pr-downloads TAG=v1.0.1"

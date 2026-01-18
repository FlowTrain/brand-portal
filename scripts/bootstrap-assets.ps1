
<# Bootstrap minimal assets & folders so v1.0.1 can ship end-to-end #>
[CmdletBinding()]
param()

function New-Dir($p) { if (-not (Test-Path $p)) { New-Item -ItemType Directory -Force -Path $p | Out-Null } }

# 1) Canonical folders
$dirs = @(
  "website\microsite\assets\css",
  "branding\exports",
  "branding\logo\svg",
  "themes\windows",
  "themes\macos",
  "cursors\windows",
  "docs\notion",
  "docs\confluence",
  "docs\github",
  "motion",
  "scripts",
  "release",
  "dist"
)
$dirs | ForEach-Object { New-Dir $_ }

# 2) Minimal dark CSS (if missing)
$cssPath = "website\microsite\assets\css\style.css"
if (-not (Test-Path $cssPath)) {
  @"
:root { color-scheme: dark; }
body { margin:0; font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial; background:#0b121a; color:#dbe6ff; }
.banner { height: 300px; background: linear-gradient(180deg,#0b121a,#0e1622); display:flex; align-items:center; justify-content:center; }
.banner img { max-height: 140px; filter: drop-shadow(0 0 18px rgba(43,174,228,.35)) drop-shadow(0 0 4px rgba(90,79,207,.25)); }
h1,h2,h3 { color:#e7f0ff; }
a { color:#7dd3fc; }
"@ | Set-Content -Encoding UTF8 $cssPath
}

# 3) Minimal placeholder SVG wordmark (if missing)
$logoSvg = "website\microsite\assets\logo.svg"
if (-not (Test-Path $logoSvg)) {
  @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 300">
  <defs>
    <linearGradient id="g" x1="0" x2="1">
      <stop offset="20%" stop-color="#5155a5"/><stop offset="100%" stop-color="#00b0f0"/>
    </linearGradient>
  </defs>
  <rect width="1200" height="300" fill="none"/>
  <text x="50%" y="55%" dominant-baseline="middle" text-anchor="middle"
        fill="url(#g)" font-family="Segoe UI, Roboto, Arial" font-size="120" letter-spacing="2">
    FlowTrain
  </text>
</svg>
"@ | Set-Content -Encoding UTF8 $logoSvg
}

# 4) 1x1 dark PNG placeholders (banner + @2x)
# Base64 for a 1x1 PNG (black-ish): iVBOR… (valid tiny PNG)
$pngB64 = @"
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/w8AAgMBg3h0x4UAAAAASUVORK5CYII=
"@.Trim()

$banner = "website\microsite\assets\banner-dark.png"
$banner2 = "website\microsite\assets\banner-dark@2x.png"
if (-not (Test-Path $banner))  { [IO.File]::WriteAllBytes($banner,  [Convert]::FromBase64String($pngB64)) }
if (-not (Test-Path $banner2)) { [IO.File]::WriteAllBytes($banner2, [Convert]::FromBase64String($pngB64)) }

# 5) Placeholder package content
$placeholders = @{
  "themes\windows\README.txt"      = "Windows Theme Pack placeholder"
  "themes\macos\README.txt"        = "macOS Wallpapers placeholder"
  "cursors\windows\README.txt"     = "Cursor Set placeholder"
  "docs\notion\README.md"          = "# Notion Kit placeholder"
  "docs\confluence\README.md"      = "# Confluence Kit placeholder"
  "docs\github\README.md"          = "# GitHub Kit placeholder"
  "motion\README.md"               = "# Motion assets placeholder"
}
$placeholders.GetEnumerator() | ForEach-Object {
  if (-not (Test-Path $_.Key)) { $_.Value | Set-Content -Encoding UTF8 $_.Key }
}

Write-Host "✓ Bootstrap created minimal files and folders." -ForegroundColor Green
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  make package checksums notes-template verify" -ForegroundColor Yellow
Write-Host "  make release TAG=v1.0.1 TITLE='v1.0.1 — Microsite + System Assets'" -ForegroundColor Yellow
Write-Host "  make update-downloads TAG=v1.0.1 && make pr-downloads TAG=v1.0.1" -ForegroundColor Yellow

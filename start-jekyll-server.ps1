# Start Jekyll Development Server
# This script starts the Jekyll server for the brand-portal microsite
# It checks if the server is already running and kills it before starting a new instance

$jekyllPath = Join-Path $PSScriptRoot "website\microsite"

# Check if Jekyll (ruby process) is already running on port 4000
Write-Host "Checking for existing Jekyll server..." -ForegroundColor Yellow
$existingProcess = Get-Process ruby -ErrorAction SilentlyContinue
if ($existingProcess) {
  Write-Host "Found existing Jekyll process(es). Stopping..." -ForegroundColor Yellow
  Stop-Process -Name ruby -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 2
  Write-Host "Existing Jekyll process stopped." -ForegroundColor Green
}

Write-Host "Starting Jekyll server for brand-portal microsite..." -ForegroundColor Green
Write-Host "Site directory: $jekyllPath" -ForegroundColor Cyan

Push-Location $jekyllPath

# Install dependencies if needed
Write-Host "Installing/updating dependencies..." -ForegroundColor Yellow
bundle install

# Start the Jekyll server
Write-Host "Starting Jekyll server..." -ForegroundColor Green
Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Jekyll will be available at:" -ForegroundColor Cyan
Write-Host "  http://localhost:4000" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

bundle exec jekyll serve @("--watch", "--incremental")

Pop-Location

# Start Jekyll Development Server
# This script starts the Jekyll server for the brand-portal microsite

$jekyllPath = Join-Path $PSScriptRoot "website\microsite"

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

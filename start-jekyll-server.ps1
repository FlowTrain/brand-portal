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
bundle exec jekyll serve --watch --incremental

Pop-Location

$ErrorActionPreference = "Stop"

Write-Host "Running local build stage..."
./scripts/local-build.ps1

Write-Host "Running local test stage..."
./scripts/local-test.ps1

Write-Host "Running local deploy stage..."
./scripts/local-deploy.ps1

Write-Host "Running local smoke test stage..."
./scripts/local-smoke.ps1

Write-Host "Local pipeline completed successfully!"

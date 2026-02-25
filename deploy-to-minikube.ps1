#!/usr/bin/env pwsh
# Deploy Wedding Site to Minikube
# This script builds the Docker image and deploys to Minikube using Helm

param(
    [switch]$SkipBuild,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

Write-Host "=== Wedding Site Minikube Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Handle uninstall
if ($Uninstall) {
    Write-Host "Uninstalling wedding-site from Minikube..." -ForegroundColor Yellow
    helm uninstall wedding-site
    Write-Host "Successfully uninstalled" -ForegroundColor Green
    exit 0
}

# Check if Minikube is running
Write-Host "Checking Minikube status..." -ForegroundColor Yellow
$minikubeStatus = minikube status --format='{{.Host}}' 2>$null
if ($minikubeStatus -ne "Running") {
    Write-Host "Starting Minikube with Docker Desktop..." -ForegroundColor Yellow
    minikube start --driver=docker --memory=4096 --cpus=4
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start Minikube"
    }
    Write-Host "Minikube started" -ForegroundColor Green
} else {
    Write-Host "Minikube is running" -ForegroundColor Green
}
Write-Host ""

# Configure Docker to use Minikube's daemon
if (-not $SkipBuild) {
    Write-Host "Configuring Docker to use Minikube's daemon..." -ForegroundColor Yellow
    & minikube -p minikube docker-env --shell powershell | Invoke-Expression
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to configure Docker environment"
    }
    Write-Host "Docker environment configured" -ForegroundColor Green
    Write-Host ""

    # Build Docker image
    Write-Host "Building Docker image 'wedding-site:local'..." -ForegroundColor Yellow
    docker build -t wedding-site:local .
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to build Docker image"
    }
    Write-Host "Docker image built successfully" -ForegroundColor Green
    Write-Host ""

    # Verify image
    Write-Host "Verifying image..." -ForegroundColor Yellow
    $image = docker images wedding-site:local --format "{{.Repository}}:{{.Tag}}"
    if ($image) {
        Write-Host "Image available: $image" -ForegroundColor Green
    } else {
        Write-Error "Image not found in Minikube's Docker daemon"
    }
    Write-Host ""
}

# Check if Helm release exists
Write-Host "Checking for existing Helm release..." -ForegroundColor Yellow
$existingRelease = helm list -q | Select-String "^wedding-site$"
if ($existingRelease) {
    Write-Host "Upgrading existing Helm release..." -ForegroundColor Yellow
    helm upgrade wedding-site ./wedding-site-chart
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to upgrade Helm release"
    }
    Write-Host "Helm release upgraded" -ForegroundColor Green
} else {
    Write-Host "Installing Helm chart..." -ForegroundColor Yellow
    helm install wedding-site ./wedding-site-chart
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Helm chart"
    }
    Write-Host "Helm chart installed" -ForegroundColor Green
}
Write-Host ""

# Wait for deployment to be ready
Write-Host "Waiting for deployment to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=120s deployment/wedding-site-deploy
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Deployment did not become ready in time, checking status..."
}
Write-Host ""

# Show deployment status
Write-Host "=== Deployment Status ===" -ForegroundColor Cyan
kubectl get pods -l app=wedding-site
Write-Host ""
kubectl get services -l app=wedding-site
Write-Host ""

# Get service URL
Write-Host "=== Access Information ===" -ForegroundColor Cyan
Write-Host "Getting service URL..." -ForegroundColor Yellow
$serviceUrl = minikube service wedding-site-svc --url
Write-Host ""
Write-Host "Site is available at: $serviceUrl" -ForegroundColor Green
Write-Host ""
Write-Host "To open in browser, run:" -ForegroundColor Yellow
Write-Host "  minikube service wedding-site-svc" -ForegroundColor White
Write-Host ""
Write-Host "To view logs, run:" -ForegroundColor Yellow
Write-Host "  kubectl logs -l app=wedding-site -f" -ForegroundColor White
Write-Host ""
Write-Host "To uninstall, run:" -ForegroundColor Yellow
Write-Host "  .\deploy-to-minikube.ps1 -Uninstall" -ForegroundColor White
Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green

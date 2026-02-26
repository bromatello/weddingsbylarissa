$ErrorActionPreference = "Stop"

# -----------------------------
# Configuration
# -----------------------------
$PUSHGATEWAY_URL = "http://localhost:9091"
$PIPELINE = "wedding-site"
$ENV = "local"
$STAGE = "build"

# -----------------------------
# Build Stage
# -----------------------------
$start = Get-Date

Write-Host "[build] docker build starting..."
docker build -t wedding-site:local .

$duration = (Get-Date) - $start
$seconds = [math]::Round($duration.TotalSeconds, 2)

Write-Host "[build] duration: $seconds seconds"

# -----------------------------
# Duration Metric
# -----------------------------
$metric = "ci_pipeline_duration_seconds{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} $seconds"
Write-Host "METRIC SENT: $metric"
Invoke-WebRequest -Method Post `
    -Uri "$PUSHGATEWAY_URL/metrics/job/$STAGE" `
    -ContentType "text/plain; version=0.0.4" `
    -Body ($metric + "`n") | Out-Null

# -----------------------------
# Status Metric
# -----------------------------
$metric = "ci_pipeline_status{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} 1"
Write-Host "METRIC SENT: $metric"
Invoke-WebRequest -Method Post `
    -Uri "$PUSHGATEWAY_URL/metrics/job/$STAGE" `
    -ContentType "text/plain; version=0.0.4" `
    -Body ($metric + "`n") | Out-Null

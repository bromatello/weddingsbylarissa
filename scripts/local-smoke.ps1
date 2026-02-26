$ErrorActionPreference = "Stop"

$PUSHGATEWAY_URL = "http://localhost:9091"
$PIPELINE = "wedding-site"
$ENV = "local"
$STAGE = "smoke"

$start = Get-Date

Write-Host "[smoke] Running smoke test..."

# Get service URL from Minikube
$URL = minikube service wedding-site-chart-svc -n monitoring --url | Select-Object -First 1

Write-Host "[smoke] Hitting $URL..."
curl.exe -sf $URL | Out-Null

$duration = (Get-Date) - $start
$seconds = [math]::Round($duration.TotalSeconds, 2)
Write-Host "[smoke] Duration: $seconds seconds"

# Duration metric
$metric = "ci_stage_duration_seconds{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} $seconds"
curl.exe -X POST -H "Content-Type: text/plain" --data-binary "$metric" "$PUSHGATEWAY_URL/metrics/job/$STAGE"

# Status metric
$metric = "ci_stage_status{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} 1"
curl.exe -X POST -H "Content-Type: text/plain" --data-binary "$metric" "$PUSHGATEWAY_URL/metrics/job/$STAGE"

$ErrorActionPreference = "Stop"

$PUSHGATEWAY_URL = "http://localhost:9091"
$PIPELINE = "wedding-site"
$ENV = "local"
$STAGE = "deploy"

$start = Get-Date

Write-Host "[deploy] Helm upgrade..."
helm upgrade --install wedding-site-chart ./wedding-site-chart -n monitoring --create-namespace

Write-Host "[deploy] Waiting for rollout..."
kubectl rollout status deploy/wedding-site-chart-deploy -n monitoring

$duration = (Get-Date) - $start
$seconds = [math]::Round($duration.TotalSeconds, 2)
Write-Host "[deploy] Duration: $seconds seconds"

# Duration metric
$metric = "ci_stage_duration_seconds{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} $seconds"
curl.exe -X POST -H "Content-Type: text/plain" --data-binary "$metric" "$PUSHGATEWAY_URL/metrics/job/$STAGE"

# Status metric
$metric = "ci_stage_status{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} 1"
curl.exe -X POST -H "Content-Type: text/plain" --data-binary "$metric" "$PUSHGATEWAY_URL/metrics/job/$STAGE"

$ErrorActionPreference = "Stop"

$PUSHGATEWAY_URL = "http://localhost:9091"
$PIPELINE = "wedding-site"
$ENV = "local"
$STAGE = "test"

$start = Get-Date

Write-Host "[test] Running tests..."
# Replace this with your real test command
Start-Sleep -Seconds 2

$duration = (Get-Date) - $start
$seconds = [math]::Round($duration.TotalSeconds, 2)
Write-Host "[test] Duration: $seconds seconds"

# Duration metric
$metric = "ci_stage_duration_seconds{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} $seconds"
curl.exe -X POST -H "Content-Type: text/plain" --data-binary "$metric" "$PUSHGATEWAY_URL/metrics/job/$STAGE"

# Status metric
$metric = "ci_stage_status{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`"} 1"
curl.exe -X POST -H "Content-Type: text/plain" --data-binary "$metric" "$PUSHGATEWAY_URL/metrics/job/$STAGE"

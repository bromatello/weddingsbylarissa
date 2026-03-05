$ErrorActionPreference = "Stop"

$PUSHGATEWAY_URL = "http://localhost:9091"
$PIPELINE = "wedding-site"
$ENV = "local"
$STAGE = "smoke"
$COMMIT = $env:CI_COMMIT
$BRANCH = $env:CI_BRANCH
$TRIGGERED_BY = $env:CI_TRIGGERED_BY
$LOG_URL_BASE = $env:CI_LOG_URL_BASE
$ARTIFACT = $env:CI_ARTIFACT
$CHANGE_SUMMARY = $env:CI_CHANGE_SUMMARY

if (-not $COMMIT) { $COMMIT = "unknown" }
if (-not $BRANCH) { $BRANCH = "unknown" }
if (-not $TRIGGERED_BY) { $TRIGGERED_BY = "unknown" }
if (-not $LOG_URL_BASE) { $LOG_URL_BASE = "http://localhost:3000/explore" }
if (-not $ARTIFACT) { $ARTIFACT = "none" }
if (-not $CHANGE_SUMMARY) { $CHANGE_SUMMARY = "local-run" }

$LOG_URL = "$LOG_URL_BASE?stage=$STAGE&commit=$COMMIT"

$start = Get-Date

Write-Host "[smoke] Running smoke test..."

# Get service URL from Minikube without starting a tunnel
$minikubeIp = (minikube ip) 2>$null
$nodePort = (kubectl get svc wedding-site-chart-svc -n monitoring -o jsonpath="{.spec.ports[0].nodePort}") 2>$null

if (-not $minikubeIp -or -not $nodePort) {
	throw "Unable to resolve Minikube IP or service NodePort for smoke test."
}

$URL = "http://$minikubeIp`:$nodePort"

Write-Host "[smoke] Hitting $URL..."
curl.exe -sf $URL | Out-Null

$duration = (Get-Date) - $start
$seconds = [math]::Round($duration.TotalSeconds, 2)
Write-Host "[smoke] Duration: $seconds seconds"

# Duration metric
$metric = "ci_pipeline_duration_seconds{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`",commit=`"$COMMIT`",branch=`"$BRANCH`",triggered_by=`"$TRIGGERED_BY`"} $seconds"
Write-Host "METRIC SENT: $metric"
Invoke-WebRequest -Method Post `
	-Uri "$PUSHGATEWAY_URL/metrics/job/$STAGE" `
	-ContentType "text/plain; version=0.0.4" `
	-Body ($metric + "`n") -UseBasicParsing | Out-Null

# Status metric
$metric = "ci_pipeline_status{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`",commit=`"$COMMIT`",branch=`"$BRANCH`",triggered_by=`"$TRIGGERED_BY`"} 1"
Write-Host "METRIC SENT: $metric"
Invoke-WebRequest -Method Post `
	-Uri "$PUSHGATEWAY_URL/metrics/job/$STAGE" `
	-ContentType "text/plain; version=0.0.4" `
	-Body ($metric + "`n") -UseBasicParsing | Out-Null

$metric = "ci_stage_info{pipeline=`"$PIPELINE`",env=`"$ENV`",stage=`"$STAGE`",commit=`"$COMMIT`",branch=`"$BRANCH`",triggered_by=`"$TRIGGERED_BY`",log_url=`"$LOG_URL`",artifact=`"$ARTIFACT`",change_summary=`"$CHANGE_SUMMARY`"} 1"
Write-Host "METRIC SENT: $metric"
Invoke-WebRequest -Method Post `
	-Uri "$PUSHGATEWAY_URL/metrics/job/$STAGE" `
	-ContentType "text/plain; version=0.0.4" `
	-Body ($metric + "`n") -UseBasicParsing | Out-Null

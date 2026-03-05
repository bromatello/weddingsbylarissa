$ErrorActionPreference = "Stop"

$PUSHGATEWAY_URL = "http://localhost:9091"
$PROMETHEUS_URL = "http://localhost:9090"
$GRAFANA_URL = "http://localhost:3000"
$PIPELINE = "wedding-site"
$ENV = "local"
$LOG_URL_BASE = "http://localhost:3000/explore"
$ARTIFACT_DEFAULT = "none"
$CHANGE_SUMMARY_DEFAULT = "local-run"

$commit = (git rev-parse --short HEAD) 2>$null
if (-not $commit) { $commit = "unknown" }

$branch = (git rev-parse --abbrev-ref HEAD) 2>$null
if (-not $branch) { $branch = "unknown" }

$triggeredBy = (git config user.name) 2>$null
if (-not $triggeredBy) { $triggeredBy = $env:USERNAME }
if (-not $triggeredBy) { $triggeredBy = "unknown" }

$env:CI_COMMIT = $commit
$env:CI_BRANCH = $branch
$env:CI_TRIGGERED_BY = $triggeredBy
$env:CI_LOG_URL_BASE = $LOG_URL_BASE
$env:CI_ARTIFACT = $ARTIFACT_DEFAULT
$env:CI_CHANGE_SUMMARY = $CHANGE_SUMMARY_DEFAULT

Write-Host "Checking Pushgateway readiness..."
try {
	Invoke-WebRequest -Uri "$PUSHGATEWAY_URL/-/ready" -Method Get -TimeoutSec 5 -UseBasicParsing | Out-Null
	Write-Host "Pushgateway is ready."
} catch {
	Write-Error "Pushgateway is not reachable at $PUSHGATEWAY_URL. Start it before running the pipeline."
	exit 1
}

Write-Host "Checking Prometheus readiness..."
try {
	Invoke-WebRequest -Uri "$PROMETHEUS_URL/-/ready" -Method Get -TimeoutSec 5 -UseBasicParsing | Out-Null
	Write-Host "Prometheus is ready."
} catch {
	Write-Error "Prometheus is not reachable at $PROMETHEUS_URL. Start it before running the pipeline."
	exit 1
}

Write-Host "Checking Grafana readiness..."
try {
	Invoke-WebRequest -Uri "$GRAFANA_URL/api/health" -Method Get -TimeoutSec 5 -UseBasicParsing | Out-Null
	Write-Host "Grafana is ready."
} catch {
	Write-Error "Grafana is not reachable at $GRAFANA_URL. Start it before running the pipeline."
	exit 1
}

$pipelineStart = Get-Date
$pipelineStatus = 1
$pipelineError = $null

try {
	Write-Host "Running local build stage..."
	./scripts/local-build.ps1

	Write-Host "Running local test stage..."
	./scripts/local-test.ps1

	Write-Host "Running local deploy stage..."
	./scripts/local-deploy.ps1

	Write-Host "Running local smoke test stage..."
	./scripts/local-smoke.ps1
} catch {
	$pipelineStatus = 0
	$pipelineError = $_
} finally {
	$pipelineDuration = (Get-Date) - $pipelineStart
	$pipelineSeconds = [math]::Round($pipelineDuration.TotalSeconds, 2)

	try {
		$metric = "ci_pipeline_info{pipeline=`"$PIPELINE`",env=`"$ENV`",commit=`"$commit`",branch=`"$branch`",triggered_by=`"$triggeredBy`"} 1"
		Write-Host "METRIC SENT: $metric"
		Invoke-WebRequest -Method Post `
			-Uri "$PUSHGATEWAY_URL/metrics/job/pipeline" `
			-ContentType "text/plain; version=0.0.4" `
			-Body ($metric + "`n") -UseBasicParsing | Out-Null

		$metric = "ci_pipeline_duration_seconds{pipeline=`"$PIPELINE`",env=`"$ENV`",commit=`"$commit`",branch=`"$branch`",triggered_by=`"$triggeredBy`"} $pipelineSeconds"
		Write-Host "METRIC SENT: $metric"
		Invoke-WebRequest -Method Post `
			-Uri "$PUSHGATEWAY_URL/metrics/job/pipeline" `
			-ContentType "text/plain; version=0.0.4" `
			-Body ($metric + "`n") -UseBasicParsing | Out-Null

		$metric = "ci_pipeline_status{pipeline=`"$PIPELINE`",env=`"$ENV`",commit=`"$commit`",branch=`"$branch`",triggered_by=`"$triggeredBy`"} $pipelineStatus"
		Write-Host "METRIC SENT: $metric"
		Invoke-WebRequest -Method Post `
			-Uri "$PUSHGATEWAY_URL/metrics/job/pipeline" `
			-ContentType "text/plain; version=0.0.4" `
			-Body ($metric + "`n") -UseBasicParsing | Out-Null
	} catch {
		Write-Error "Failed to push pipeline metrics: $($_.Exception.Message)"
	}
}

if ($pipelineStatus -eq 0) {
	Write-Warning "Local pipeline completed with failures."
	if ($pipelineError) {
		Write-Warning $pipelineError
	}
} else {
	Write-Host "Local pipeline completed successfully!"
}

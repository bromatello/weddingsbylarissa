# Local monitoring runbook (Prometheus + Grafana + Pushgateway)

This is a quick checklist to restore local monitoring after a reboot.

## 1) Deploy or upgrade the chart

```
helm upgrade --install wedding-site-chart ./wedding-site-chart -n monitoring --create-namespace
```

## 2) Push a build metric

```
./scripts/local-build.ps1
```

## 3) Verify Pushgateway has metrics

```
curl http://localhost:9091/metrics
```

You should see metrics like:
- ci_pipeline_duration_seconds
- ci_pipeline_status

## 4) Verify Prometheus is scraping Pushgateway

```
kubectl get servicemonitor -n monitoring | findstr pushgateway
```

In Prometheus, run:
```
ci_pipeline_status
```

If it returns data, Prometheus is scraping.

## 5) Fix Grafana variable (if panels are empty)

Make sure the dashboard variable $env includes the value local.

Recommended variable query:
```
label_values(ci_pipeline_status, env)
```

Then set the dashboard to env = local.

## Notes

- Pushgateway ServiceMonitor is enabled by default in wedding-site-chart/values.yaml.
- The ServiceMonitor targets the monitoring namespace and the prometheus-pushgateway service.
- Metrics are posted from scripts/local-build.ps1 using Prometheus text format.

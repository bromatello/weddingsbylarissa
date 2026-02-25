# Local Testing Checklist

## Quick Local Testing

### 1. **Run Unit Tests** ✅
```powershell
npm test
```
- Validates HTML structure, links, content
- All 30 tests should pass

### 2. **Start Local Server** 🌐
```powershell
npm start
```
- Opens at `http://localhost:5000` (or next available port)
- Best for quick development/preview
- Press `Ctrl+C` to stop

### 3. **Test in Minikube** (Optional - Full K8s Test) 🚢
```powershell
.\deploy-to-minikube.ps1
```
- Builds Docker container
- Deploys to local Kubernetes
- Access via: `minikube service wedding-site-svc`
- Tests the full production-like environment

---

## Local Metrics: Prometheus + Grafana (Tests & Stages)

### A. Start local Prometheus + Grafana + Pushgateway
```powershell
docker compose up -d
```
This repo already includes a docker-compose file that can run:
- **Prometheus** (scrapes metrics)
- **Grafana** (dashboards)
- **Pushgateway** (where your pipeline pushes test status)

### B. Confirm Pushgateway URL
Use this local URL in your scripts/tests:
```
http://localhost:9091
```

### C. Emit test results locally (example)
After each local test stage, push a metric to Pushgateway:
```powershell
@"
pipeline_stage_status{stage="unit_tests"} 1
pipeline_stage_duration_seconds{stage="unit_tests"} 12
"@ | curl.exe --data-binary @- "http://localhost:9091/metrics/job/local_tests"
```
- **status**: 1 = pass, 0 = fail
- **duration_seconds**: how long the stage took

### D. Grafana access
Open Grafana:
```
http://localhost:3000
```
Default login is typically `admin` / `admin` (you may be prompted to change it).

### E. Prometheus access
```
http://localhost:9090
```
Verify metrics are arriving by searching for:
```
pipeline_stage_status
pipeline_stage_duration_seconds
```

---

## Local Stage Reporting (Suggested Stages)

Push these stages after each step:
- `precommit`
- `security`
- `quality_and_tests`
- `sonarcloud`
- `docker_scout`
- `smoke_test`
- `deploy_local`

This mirrors the GitHub Actions pipeline so your local runs look identical in Grafana.

---

## Development Workflow

### Making Changes
1. Edit HTML/CSS files
2. Run `npm test` to verify
3. Run `npm start` to preview
4. Fix any issues
5. Repeat until satisfied

### Before Pushing to GitHub
```powershell
# Run tests
npm test

# Optional: Full container test
.\deploy-to-minikube.ps1
```

### Push to GitHub
```powershell
git add .
git commit -m "Your change description"
git push origin main
```
- GitHub Actions pipeline runs automatically
- Tests, security scans, build, and deploy to production

---

## Stopping Services

**Stop local server:** `Ctrl+C` in the terminal

**Stop Minikube:**
```powershell
minikube stop
```

**Uninstall from Minikube:**
```powershell
.\deploy-to-minikube.ps1 -Uninstall
```

---

## Troubleshooting

**Port already in use?** Server will automatically pick next available port

**Minikube tunnel issues?** Use `minikube service wedding-site-svc` instead of direct IP

**Tests failing?** Check the error messages - usually missing files or broken links

**Images not showing?** Check file paths match actual filenames (case-sensitive!)

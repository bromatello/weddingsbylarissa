# Reset Local Minikube Environment
# Run this in PowerShell

Write-Host "🚀 Starting Minikube..."
minikube start

Write-Host "📦 Reinstalling monitoring stack (Prometheus + Grafana)..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack `
  -n monitoring --create-namespace

Write-Host "📨 Reinstalling Pushgateway..."
helm upgrade --install pushgateway prometheus-community/prometheus-pushgateway `
  -n monitoring

Write-Host "🌐 Reinstalling wedding-site chart..."
helm upgrade --install wedding-site-chart ./wedding-site-chart `
  -n monitoring

Write-Host "⏳ Waiting for pods to become ready..."
kubectl wait --for=condition=ready pod --all -n monitoring --timeout=180s

Write-Host "🔌 Starting port-forward for Pushgateway (9091)..."
Start-Process powershell -ArgumentList "kubectl port-forward svc/pushgateway-prometheus-pushgateway -n monitoring 9091:9091" -WindowStyle Minimized

Write-Host "📊 Starting port-forward for Grafana (3000)..."
Start-Process powershell -ArgumentList "kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80" -WindowStyle Minimized

Write-Host "🎉 Environment ready!"
Write-Host "Pushgateway: http://localhost:9091/metrics"
Write-Host "Grafana:     http://localhost:3000"

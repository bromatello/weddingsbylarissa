# UAT ingress runbook (GKE + Helm + DNS)

Short guide to enable ingress/LB for UAT testing, then remove it to save costs.

## 1) Set context to the UAT cluster

```
gcloud container clusters get-credentials <UAT_CLUSTER_NAME> --region <REGION> --project <PROJECT_ID>
```

Verify:
```
kubectl get nodes
```

## 2) Deploy UAT without ingress (cheap baseline)

```
helm upgrade --install wedding-site-uat ./wedding-site-chart \
  -n uat \
  -f wedding-site-chart/values-uat.yaml
```

## 3) Enable ingress/LB for testing

```
helm upgrade wedding-site-uat ./wedding-site-chart \
  -n uat \
  -f wedding-site-chart/values-uat.yaml \
  -f wedding-site-chart/values-uat-ingress.yaml
```

## 4) Get the ingress IP

```
kubectl get ingress -n uat
```

Wait until ADDRESS has a public IP.

## 5) Create DNS record (Cloud DNS)

```
gcloud dns record-sets transaction start --zone=<DNS_ZONE>

gcloud dns record-sets transaction add <INGRESS_IP> \
  --name=uat-weddings.<your-domain>. \
  --ttl=300 \
  --type=A \
  --zone=<DNS_ZONE>

gcloud dns record-sets transaction execute --zone=<DNS_ZONE>
```

## 6) Run tests

Hit:
```
https://uat-weddings.<your-domain>
```

## 7) Remove ingress/LB to stop costs

```
helm upgrade wedding-site-uat ./wedding-site-chart \
  -n uat \
  -f wedding-site-chart/values-uat.yaml
```

## 8) Remove DNS record

```
gcloud dns record-sets transaction start --zone=<DNS_ZONE>

gcloud dns record-sets transaction remove <INGRESS_IP> \
  --name=uat-weddings.<your-domain>. \
  --ttl=300 \
  --type=A \
  --zone=<DNS_ZONE>

gcloud dns record-sets transaction execute --zone=<DNS_ZONE>
```

## Notes

- The chart creates an Ingress only when ingress.enabled is true.
- If you use a specific ingress class, set ingress.className in values-uat-ingress.yaml.

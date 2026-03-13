#!/bin/bash
set -euo pipefail

AWS_REGION="${1:?aws region is required}"
EKS_CLUSTER_NAME="${2:?eks cluster name is required}"

aws eks update-kubeconfig --region "${AWS_REGION}" --name "${EKS_CLUSTER_NAME}"

# Wait for worker nodes before installing the monitoring stack.
for _ in $(seq 1 30); do
  if kubectl get nodes >/dev/null 2>&1; then
    break
  fi
  sleep 20
done

kubectl get nodes

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --wait \
  --timeout 20m \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer

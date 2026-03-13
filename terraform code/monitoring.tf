locals {
  monitoring_namespace    = var.install_monitoring_stack ? "monitoring" : ""
  grafana_service_name    = var.install_monitoring_stack ? "monitoring-grafana" : ""
  prometheus_service_name = var.install_monitoring_stack ? "monitoring-kube-prometheus-prometheus" : ""
}

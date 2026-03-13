output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.vm.public_ip
}

output "instance_id" {
  description = "ID of EC2 instance"
  value       = aws_instance.vm.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.main.id
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i /path/to/key.pem ubuntu@${aws_instance.vm.public_ip}"
}

output "sonarqube_ssh_command" {
  description = "SSH command to connect to SonarQube VM"
  value       = "ssh -i /path/to/key.pem ubuntu@${aws_instance.sonarqube_vm.public_ip}"
}

output "jenkins_url" {
  description = "External Jenkins URL"
  value       = "http://${aws_instance.vm.public_ip}:8080"
}

output "sonarqube_url" {
  description = "External SonarQube URL"
  value       = "http://${aws_instance.sonarqube_vm.public_ip}:9000"
}

output "jenkins_initial_admin_password_command" {
  description = "Command to fetch Jenkins initial admin password"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.vm.public_ip} 'sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'"
}

output "ecr_repository_url" {
  description = "ECR repository URL for application images"
  value       = aws_ecr_repository.app.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_update_kubeconfig_command" {
  description = "Command to configure kubectl for EKS"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  value       = local.monitoring_namespace
}

output "grafana_service_name" {
  description = "Grafana service name in monitoring namespace"
  value       = local.grafana_service_name
}

output "prometheus_service_name" {
  description = "Prometheus service name in monitoring namespace"
  value       = local.prometheus_service_name
}

output "grafana_lb_hostname_command" {
  description = "Command to get the Grafana load balancer hostname"
  value       = var.install_monitoring_stack ? "ssh -i ${var.private_key_path} ubuntu@${aws_instance.vm.public_ip} 'kubectl get svc ${local.grafana_service_name} -n ${local.monitoring_namespace} -o jsonpath=\"{.status.loadBalancer.ingress[0].hostname}\"'" : ""
}

output "prometheus_lb_hostname_command" {
  description = "Command to get the Prometheus load balancer hostname"
  value       = var.install_monitoring_stack ? "ssh -i ${var.private_key_path} ubuntu@${aws_instance.vm.public_ip} 'kubectl get svc ${local.prometheus_service_name} -n ${local.monitoring_namespace} -o jsonpath=\"{.status.loadBalancer.ingress[0].hostname}\"'" : ""
}

output "grafana_open_command" {
  description = "Command to print a browser-ready Grafana URL"
  value       = var.install_monitoring_stack ? "echo http://$(ssh -i ${var.private_key_path} ubuntu@${aws_instance.vm.public_ip} 'kubectl get svc ${local.grafana_service_name} -n ${local.monitoring_namespace} -o jsonpath=\"{.status.loadBalancer.ingress[0].hostname}\"')" : ""
}

output "prometheus_open_command" {
  description = "Command to print a browser-ready Prometheus URL"
  value       = var.install_monitoring_stack ? "echo http://$(ssh -i ${var.private_key_path} ubuntu@${aws_instance.vm.public_ip} 'kubectl get svc ${local.prometheus_service_name} -n ${local.monitoring_namespace} -o jsonpath=\"{.status.loadBalancer.ingress[0].hostname}\"')" : ""
}

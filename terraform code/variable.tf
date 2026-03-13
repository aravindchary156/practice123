variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "sonarqube_instance_type" {
  description = "EC2 instance type for the dedicated SonarQube VM"
  type        = string
  default     = "t3.small"
}

variable "ssh_key_name" {
  description = "SSH key pair name"
  type        = string
}
variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to access SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] // Change this to restrict SSH access as needed
}

variable "private_key_path" {
  description = "Path to the private key file for SSH connection"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name for application images"
  type        = string
  default     = "boardgame"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "hackathon-eks"
}

variable "eks_node_instance_types" {
  description = "EKS node group instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired EKS node group size"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Minimum EKS node group size"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum EKS node group size"
  type        = number
  default     = 3
}

variable "install_monitoring_stack" {
  description = "Install Prometheus and Grafana in EKS using kube-prometheus-stack Helm chart"
  type        = bool
  default     = true
}

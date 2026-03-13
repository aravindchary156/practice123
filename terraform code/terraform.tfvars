aws_region       = "ap-south-1"
ssh_key_name     = "hackathon-india-key-1"
private_key_path = "/Users/maravind/.ssh/hackathon-india-key-1.pem"

instance_type           = "t3.micro"
sonarqube_instance_type = "m7i-flex.large"

ecr_repository_name      = "boardgame"
eks_cluster_name         = "hackathon-eks"
eks_node_instance_types  = ["t3.small"]
eks_node_desired_size    = 3
eks_node_min_size        = 3
eks_node_max_size        = 4
install_monitoring_stack = true

resource "null_resource" "setup_tools" {
  triggers = {
    install_script_hash = filesha256("${path.module}/install_tools.sh")
    instance_id         = aws_instance.vm.id
  }

  depends_on = [aws_instance.vm]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.vm.public_ip
    private_key = file(var.private_key_path)
    timeout     = "10m"
  }

  provisioner "file" {
    source      = "${path.module}/install_tools.sh"
    destination = "/home/ubuntu/install_tools.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install_tools.sh",
      "sudo bash /home/ubuntu/install_tools.sh",
    ]
  }
}

resource "null_resource" "setup_sonarqube" {
  triggers = {
    install_script_hash = filesha256("${path.module}/install_sonarqube.sh")
    instance_id         = aws_instance.sonarqube_vm.id
  }

  depends_on = [aws_instance.sonarqube_vm]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.sonarqube_vm.public_ip
    private_key = file(var.private_key_path)
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "cat > /tmp/install_sonarqube.sh <<'SCRIPT'\n${file("${path.module}/install_sonarqube.sh")}\nSCRIPT",
      "sudo mv /tmp/install_sonarqube.sh /usr/local/bin/install_sonarqube.sh",
      "sudo chmod +x /usr/local/bin/install_sonarqube.sh",
      "sudo bash -c 'nohup /usr/local/bin/install_sonarqube.sh > /var/log/install_sonarqube.log 2>&1 </dev/null & echo $! > /var/run/install_sonarqube.pid'",
      "sleep 5",
      "sudo test -s /var/run/install_sonarqube.pid",
    ]
  }
}

resource "null_resource" "install_monitoring_stack" {
  count = var.install_monitoring_stack ? 1 : 0

  triggers = {
    monitoring_script_hash = filesha256("${path.module}/install_monitoring.sh")
    cluster_name           = aws_eks_cluster.main.name
    aws_region             = var.aws_region
    instance_id            = aws_instance.vm.id
  }

  depends_on = [
    null_resource.setup_tools,
    null_resource.setup_sonarqube,
    aws_eks_node_group.main,
    aws_eks_access_policy_association.jenkins_cluster_admin
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.vm.public_ip
    private_key = file(var.private_key_path)
    timeout     = "10m"
  }

  provisioner "file" {
    source      = "${path.module}/install_monitoring.sh"
    destination = "/home/ubuntu/install_monitoring.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install_monitoring.sh",
      "sudo bash -c 'nohup /home/ubuntu/install_monitoring.sh ${var.aws_region} ${aws_eks_cluster.main.name} > /var/log/install_monitoring.log 2>&1 </dev/null & echo $! > /var/run/install_monitoring.pid'",
      "sleep 5",
      "sudo test -s /var/run/install_monitoring.pid",
    ]
  }
}

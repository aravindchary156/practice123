resource "null_resource" "setup_tools" {
  triggers = {
    install_script_hash = filesha256("${path.module}/install_tools.sh")
  }

  depends_on = [aws_instance.vm]

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${var.private_key_path} ${path.module}/install_tools.sh ubuntu@${aws_instance.vm.public_ip}:/home/ubuntu/install_tools.sh"
  }

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -i ${var.private_key_path} ubuntu@${aws_instance.vm.public_ip} 'chmod +x /home/ubuntu/install_tools.sh && sudo /home/ubuntu/install_tools.sh'"
  }
}

resource "aws_instance" "vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.main.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_ec2.name

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [instance_type]
  }

  tags = {
    Name = "hackathon-vm"
  }

  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.main
  ]
}

resource "aws_instance" "sonarqube_vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.sonarqube_instance_type
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.main.id]

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "hackathon-sonarqube-vm"
  }

  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.main
  ]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

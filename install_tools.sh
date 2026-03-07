#!/bin/bash
set -euo pipefail

# Remove stale Jenkins apt repo/key from previous failed runs.
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /etc/apt/keyrings/jenkins-keyring.gpg

sudo apt update -y
sudo apt install -y docker.io unzip wget apt-transport-https gnupg lsb-release curl ca-certificates fontconfig openjdk-17-jre awscli

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu || true

# Install Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update
sudo apt install trivy -y

# Install kubectl
KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/eksctl

# Run Jenkins as Docker container (avoids apt repo/key issues).
sudo docker rm -f jenkins >/dev/null 2>&1 || true
sudo docker volume create jenkins_home >/dev/null
sudo docker run -d --name jenkins --restart unless-stopped \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts-jdk17

# Cleanup to avoid filling small root disks.
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /tmp/*

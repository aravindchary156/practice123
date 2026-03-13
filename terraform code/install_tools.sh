#!/bin/bash
set -euo pipefail

# Remove stale Jenkins apt repo/key from previous failed runs.
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /etc/apt/keyrings/jenkins-keyring.gpg

sudo apt update -y
sudo apt install -y docker.io unzip wget apt-transport-https gnupg lsb-release curl ca-certificates fontconfig openjdk-17-jre

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu || true

# Install AWS CLI v2 for EKS authentication.
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -oq /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update
rm -rf /tmp/aws /tmp/awscliv2.zip

# Install kubectl
KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/eksctl
rm -f /tmp/eksctl

# Install Helm
HELM_VERSION="v3.18.6"
curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o /tmp/helm.tar.gz
tar -xzf /tmp/helm.tar.gz -C /tmp
sudo install -m 0755 /tmp/linux-amd64/helm /usr/local/bin/helm
rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

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

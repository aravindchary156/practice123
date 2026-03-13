#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

retry() {
  local attempts="$1"
  shift
  local n=1
  until "$@"; do
    if [ "$n" -ge "$attempts" ]; then
      return 1
    fi
    n=$((n + 1))
    sleep 10
  done
}

retry 5 sudo apt update -y
retry 5 sudo apt install -y docker.io curl ca-certificates fontconfig openjdk-17-jre

sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu || true

sudo docker rm -f sonarqube >/dev/null 2>&1 || true
sudo docker volume create sonarqube_data >/dev/null
sudo docker volume create sonarqube_logs >/dev/null
sudo docker volume create sonarqube_extensions >/dev/null
sudo docker run -d --name sonarqube --restart unless-stopped \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  sonarqube:lts-community

sudo apt clean
sudo rm -rf /var/lib/apt/lists/*

#!/bin/bash
set -e

# Instalación de docker en Debian 11. Pasos basados en:
# https://docs.docker.com/engine/install/debian/

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  
apt-get update
# install the latest version of Docker Engine and containerd
apt-get install -y docker-ce docker-ce-cli containerd.io

docker run hello-world

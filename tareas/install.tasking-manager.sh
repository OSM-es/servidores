#!/bin/bash
set -e

# Actualizar máquina
sudo apt-get update

# Instalar software necesario
sudo apt-get install
	git \
	make \
	ca-certificates \
    curl \
    gnupg \
    lsb-release

# Clonar el tasking-manager
git clone https://github.com/hotosm/tasking-manager.git

# Instalar docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Instalar docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose

# Post-instalación: https://docs.docker.com/engine/install/linux-postinstall/
sudo groupadd docker
sudo usermod -aG docker $USER

####################################################
#
# SIGUIENTES PASOS:
#
# 1. Seguir las instrucciones de configuración: https://github.com/hotosm/tasking-manager/blob/develop/docs/setup-docker.md#configure
# 2. Levantar las máquinas desde la carpeta tasking-manager: make up
# 3. (Opcional) Cargar un dump de la base de datos: zcat tasking-manager.sql.gz | docker exec -i postgresql psql -U tm -d tasking-manager
#
####################################################

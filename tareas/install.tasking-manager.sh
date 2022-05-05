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
# Seguir las instrucciones de configuración:
#
# https://github.com/hotosm/tasking-manager/blob/develop/docs/setup-docker.md#configure
#
# Y por último, levantar las máquinas desde la carpeta tasking-manager
#
# make up
#
####################################################

# Crear script de arranque. Ojo, hay que cambiar "tm" por el nombre de usuario en las rutas
echo '#!/bin/bash
cd /home/tm/tasking-manager
make up' > /home/tm/arranca-tm.sh
chmod +x /home/tm/arranca-tm.sh

# Crear servicio tm. Ojo, hay que cambiar "tm" por el nombre de usuario en "User" y en la ruta en "ExecStart"
echo '[Unit]
Description=tm
After=network.target 

[Service]
Type=simple
User=tm
Restart=always
ExecStart=/home/tm/arranca-tm.sh

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/tm.service

# Activar e iniciar servicio
systemctl daemon-reload
systemctl enable tm
service tm start

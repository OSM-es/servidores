#!/bin/bash
set -e
# Antes de lanzar el script: instala sudo, créate un usuario (con tu nombre) y añádelo al grupo sudo:
# apt update && apt install -y sudo htop
# adduser tuusuario
# adduser tuusuario sudo

# Es necesario registrar una nueva aplicación en osm.org para el login:
# https://www.openstreetmap.org/user/un-usuario-osm-para-el-gestor/oauth_clients/new 
# con los permisos "leer sus preferencias de usuario" y "modificar el mapa". 
# Una vez registrada tenemos que guardar la "Clave de Consumidor" y 
# "Secreto de Consumidor:" para configurar TM_CONSUMER_KEY y TM_CONSUMER_SECRET.

#### Configura estas variables ####
DOMINIO="tareas.openstreetmap.es"

# OpenStreetMap OAuth consumer key and secret (required)
TM_CONSUMER_KEY=XXXXXXXXXXXXXXXXXXXXXXXX
TM_CONSUMER_SECRET=XXXXXXXXXXXXXXXXXXXXXXXX

# Email
TM_EMAIL_FROM_ADDRESS=XXXXXXXXXXXXXXXXXXXXXXXX
TM_SMTP_HOST=XXXXXXXXXXXXXXXXXXXXXXXX
TM_SMTP_PORT=587
TM_SMTP_USER=XXXXXXXXXXXXXXXXXXXXXXXX
TM_SMTP_PASSWORD=XXXXXXXXXXXXXXXXXXXXXXXX

#### Fin de la configuración del script ####

# Usuario que lanzará el tasking-manager
USUARIOTM="tm"

# A freely definable secret. Gives authorization to the front and and backend to talk to each other.
TM_SECRET=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`

# Actualizar el sistema
sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y

# Crear usuario tm con contraseña aleatoria
PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
CRYPT=$(perl -e 'print crypt($ARGV[0], "password")' $PASS)
sudo useradd -m -p "$CRYPT" "$USUARIOTM"

# Instalar software necesario
sudo apt-get install -y git make ca-certificates curl gnupg lsb-release rsync

# Clonar el tasking-manager
cd /home/$USUARIOTM
sudo -u $USUARIOTM git clone https://github.com/hotosm/tasking-manager.git
# Preguntar al usuario qué versión del TM desea instalar, si no introduce ninguna, se instalar
cd tasking-manager
read -p "Introduce la versión del TM que corresponda con la backup que tengas, ej. v4.4.4 (no olvides la letra 'v'); si no tienes ninguna, se instalará la versión más moderna ($(git describe --tags --abbrev=0)): " VERSION
VERSION=${VERSION:-$(sudo -u $USUARIOTM git describe --tags --abbrev=0)}
sudo -u $USUARIOTM git checkout "${VERSION}"

# Instalar docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Instalar docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo curl \
  -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
  -o /etc/bash_completion.d/docker-compose

# Post-instalación: https://docs.docker.com/engine/install/linux-postinstall/
# sudo groupadd docker # No es necesario, ya existe el grupo
sudo usermod -aG docker $USUARIOTM

# Configuración del tasking-manager: tasking-manager.env, docker-compose.yml y docker-compose.override.yml.
cd /home/$USUARIOTM/tasking-manager

# Descarga de las plantillas preconfiguradas
sudo -u $USUARIOTM  curl -L "https://raw.githubusercontent.com/OSM-es/servidores/master/tareas/tasking-manager.env" -o tasking-manager.env
sudo -u $USUARIOTM  curl -L "https://raw.githubusercontent.com/OSM-es/servidores/master/tareas/docker-compose.yml" -o docker-compose.yml
sudo -u $USUARIOTM  curl -L "https://raw.githubusercontent.com/OSM-es/servidores/master/tareas/docker-compose.override.yml" -o docker-compose.override.yml

# Aplicar la configuración según las variables
sudo -u $USUARIOTM  sed -i "s/XXXXDOMINIOXXXX/$DOMINIO/" docker-compose.yml
sudo -u $USUARIOTM  sed -i "s/XXXXDOMINIOXXXX/$DOMINIO/" docker-compose.override.yml
sudo -u $USUARIOTM  sed -i "s/XXXXDOMINIOXXXX/$DOMINIO/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_SECRETXXXX/$TM_SECRET/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_CONSUMER_KEYXXXX/$TM_CONSUMER_KEY/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_CONSUMER_SECRETXXXX/$TM_CONSUMER_SECRET/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_EMAIL_FROM_ADDRESSXXXX/$TM_EMAIL_FROM_ADDRESS/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_SMTP_HOSTXXXX/$TM_SMTP_HOST/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_SMTP_PORTXXXX/$TM_SMTP_PORT/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_SMTP_USERXXXX/$TM_SMTP_USER/" tasking-manager.env
sudo -u $USUARIOTM  sed -i "s/XXXXTM_SMTP_PASSWORDXXXX/$TM_SMTP_PASSWORD/" tasking-manager.env

# Levantar las máquinas desde la carpeta tasking-manager: make up
sudo -u $USUARIOTM make up

# Script para hacer copias de seguridad de la base de datos.
sudo apt-get install -y cron coreutils
sudo -u $USUARIOTM curl -L "https://raw.githubusercontent.com/OSM-es/servidores/master/tareas/database-backup.sh" -o /home/$USUARIOTM/database-backup.sh
sudo -u $USUARIOTM chmod +x /home/$USUARIOTM/database-backup.sh
# Corre todos los días a las 2:45AM
echo "45 2 * * * $USUARIOTM SHELL=/bin/bash /home/$USUARIOTM/database-backup.sh" | sudo tee /etc/cron.d/database-backup

# (Opcional) Cargar un dump de la base de datos
read -p "Copia el dump de la bbdd a /home/$USUARIOTM/tasking-manager.sql.gz y pulsa Entrar para continuar... o Ctrl-C para terminar sin importar el dump."
sudo -u $USUARIOTM docker container stop backend
sudo -u $USUARIOTM docker exec -i postgresql dropdb -U tm tasking-manager
sudo -u $USUARIOTM docker exec -i postgresql createdb -U tm tasking-manager
zcat /home/$USUARIOTM/tasking-manager.sql.gz | sudo -u $USUARIOTM docker exec -i postgresql psql -U tm -d tasking-manager
sudo -u $USUARIOTM make up

echo "Todo OK, la instancia debería estar accesible aquí: https://$DOMINIO"
echo "RECORDATORIO: configurar el proxy (si hay) para que el tamaño máximo permitido sean 100MB. NGINX: client_max_body_size 100M;"
exit 0

#!/bin/bash

# Pasos para instalar la web de openstreetmap.es en Debian 11, aunque debería seguir funcionando igual en futuras versiones

# Actualizar
apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && echo "OK" 

# Instalar nginx
apt install nginx -y

# Redirección de la página principal a la wiki 
echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url='https://wiki.openstreetmap.org/wiki/ES:Espa%C3%B1a'" /></head></html>' > /var/www/html/index.html

# Redirección de openstreetmap.es/catastro a la wiki
mkdir /var/www/html/catastro
echo '<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0; url='https://wiki.openstreetmap.org/wiki/ES:Catastro_espa%C3%B1ol/Importaci%C3%B3n_de_edificios'" /></head></html>' > /var/www/html/catastro/index.html

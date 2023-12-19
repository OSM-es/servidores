# (Opcional) Este visor sirve para acceder a los logs de docker vía HTTP
docker run -d --name dozzle \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DOZZLE_BASE=/logs \ # Ruta del servidor en la que se va a montar
  -e DOZZLE_FILTER=name=backend \ # Mostrar unicamente las siguientes máquinas
  -e DOZZLE_ENABLE_ACTIONS=false \ # Deshabilitar la posibilidad de arrancar/parar máquinas
  -p 9999:8080 \
  --restart unless-stopped \
  amir20/dozzle

Como los logs son muy grandes, conviene rotarlos. Copiar el archivo 'daemon.json' y reiniciar servicio:

    cp daemon.json /etc/docker
    service docker reload

Para lanzar el servicio poner un usuario y contraseña OSM en el archivo oauth-settings.json y ejecutar

    sudo mkdir -p /var/local/overpass/db
    docker compose build
    docker compose up -d

Eliminar la contraseña de oauth-settings.json

Inspeccionar con 

    docker compose logs -f

NOTA: Tarda bastante tiempo en estar a punto

La base de datos está en /var/local/overpass/db

El contenedor se detiene o activa con 

    docker compose stop / start

El servicio responde en localhost/api/interpreter. Ejemplo:

    curl "http://localhost/api/interpreter?data=\[out:json\];node(21068295);out;"

Se actualiza cada 300 segundos

Comprobacion del estado de actualizacion

    curl http://localhost/api/estado

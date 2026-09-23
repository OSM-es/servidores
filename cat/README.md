# CatAtom2OSM Online

## Despliegue/deployment

Consta de dos servicios independientes:

    /opt/CatAtomAPI
    /opt/CatAtomWeb

Son repositorios git, en la carpeta correspondiente, se actualizan con

    /opt/CatAtomAPI
    # CatAtom2OSM.git es un "submodule"
    git pull --recurse-submodules
    
    cd /opt/CatAtomWeb
    git pull

Para tener permisos de escritura, el usuario debe pertenecer al grupo 'git'.

Para pasar a producción los cambios en CatAtomWeb, reconstruir y reiniciar el servicio

    docker-compose build         
    docker-compose down --remove-orphans
    docker-compose up -d

En el caso de CatAtomAPI, usar la macro make

    make build
    make down
    make up

Para consultar los registros

    docker-compose logs -f

## Resolución de problemas

### Projecto crasheado

A veces, un proceso de un municipio puede fallar y no es posible the borrar en el sitio web https://catastro.openstreetmap.es | Process.
Con estes pasos se puede reparar:

* borra `/var/catastro/results/<chifre_municipio>` por ejemplo: `rm -rf /var/catastro/results/03104`
* `cd /opt/CatAtomAPI`
* `make down; make up` o `docker-compose down --remove-orphans; docker-compose up -d`




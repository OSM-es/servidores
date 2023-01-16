  GNU nano 6.2                                               Nuevo búfer *                                                      
=CatAtom2OSM online=

Consta de dos servicios independientes:

/opt/CatAtomAPI
/opt/CatAtomWeb

Son repositorios git, en la carpeta correspondiente, se actualizan con

    git pull

Para tener permisos de escritura, el usuario debe pertenecer al grupo 'git'.

Para pasar a producción los cambios en CatAtomWeb, reconstruir y reiniciar el servicio

    docker-compose build         
    docker-compose down
    docker-compose up -d

En el caso de CatAtomAPI, usar la macro make

    make build
    make down
    make up

Para consultar los registros

    docker-compose logs -f

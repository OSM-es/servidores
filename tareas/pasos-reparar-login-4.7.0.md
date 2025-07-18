## July 18, 2025 - OSM-ES GH Fork

By: Just van den Broecke - https://github.com/justb4

In ~/project/openstreetmap/hot/tm/  
```
git clone https://github.com/OSM-es/tasking-manager.git fork.git  
cd fork.git  
git checkout -b osm-es-4.7.0 v4.7.0  
git push --set-upstream origin osm-es-4.7.0
```

### Deploy from new Fork

Login on 'tareas' server. 

```
sudo su - tm  
/bin/bash  
cd /home/tm

cd tasking-manager  
make down  
cd ..  
mv tasking-manager tasking-manager.v4.7.0  
git clone https://github.com/OSM-es/tasking-manager.git tasking-manager

# Need ES TM config specific files  
cp tasking-manager.v4.7.0/docker-compose\*.yml tasking-manager/  
cp tasking-manager.v4.7.0/tasking-manager.env tasking-manager/

cd tasking-manager  
# Rebuild  
docker-compose build --no-cache

docker images  
REPOSITORY TAG IMAGE ID CREATED SIZE  
hotosm-tasking-manager backend f90f0a71f171 About a minute ago 627MB  
hotosm-tasking-manager frontend c70455f3175e 3 minutes ago 260MB
```

# Cargar ultimo DB dump
```
cd /home/tm/tasking-manager  
make up

docker compose stop backend  
docker exec -i postgresql dropdb -U tm tasking-manager  
docker exec -i postgresql createdb -U tm tasking-manager  
zcat /home/tm/backups/20250718-024501.tasking-manager-v4.7.0.sql.gz | docker exec -i postgresql psql -U tm -d tasking-manager  
make down  
make up
```

## Apply Cherry-pick
```
git checkout osm-es-4.7.0-login-fix  
git cherry-pick 926a952165383e927078a20e92d61ac41f2826a7  

git cherry-pick 926a952165383e927078a20e92d61ac41f2826a7
Auto-merging frontend/src/components/header/index.js
Auto-merging frontend/src/components/header/signUp.js
Auto-merging frontend/src/components/projectDetail/shareButton.js
Auto-merging frontend/src/network/genericJSONRequest.js
CONFLICT (content): Merge conflict in frontend/src/network/genericJSONRequest.js
Auto-merging frontend/src/utils/login.js
CONFLICT (content): Merge conflict in frontend/src/utils/login.js
Auto-merging frontend/src/views/authorized.js
error: could not apply 926a95216... Fix #6932 - login isn't working
hint: After resolving the conflicts, mark them with
hint: "git add/rm <pathspec>", then run
hint: "git cherry-pick --continue".
hint: You can instead skip this commit with "git cherry-pick --skip".
hint: To abort and get back to the state before "git cherry-pick",
hint: run "git cherry-pick --abort".

# resolve conflicts  
git cherry-pick --continue
git push

# On server

cd /home/tm/tasking-manager  
git fetch  
git checkout osm-es-4.7.0-login-fix  
docker-compose build --no-cache frontend  
make down  
make up  
```

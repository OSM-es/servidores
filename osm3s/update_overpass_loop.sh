#!/usr/bin/env sh

OVERPASS_UPDATE_SLEEP=${OVERPASS_UPDATE_SLEEP:-60}
OVERPASS_DIFF_URL_ESP=${OVERPASS_DIFF_URL_ESP:-http://download.openstreetmap.fr/replication/europe/spain/minute/}
OVERPASS_DIFF_URL_CAN=${OVERPASS_DIFF_URL_CAN:-http://download.openstreetmap.fr/replication/africa/spain/canarias/minute/}
set +e
while true; do
    if [ -d /db/diffs_esp ] && [ -s /db/replicate_id_esp ]; then
        echo "Actualiza peninsula"
        rm -rf /db/diffs
        rm -f /db/replicate_id
        cp  /db/replicate_id_esp /db/replicate_id
        cp -r /db/diffs_esp /db/diffs
        OVERPASS_DIFF_URL="${OVERPASS_DIFF_URL_ESP}" /app/bin/update_overpass.sh
        if [ -d /db/diffs ] && [ -s /db/replicate_id ]; then 
            rm -rf /db/diffs_esp
            rm -f /db/replicate_id_esp
            mv /db/replicate_id /db/replicate_id_esp
            mv /db/diffs /db/diffs_esp
            echo "Fin actualiza peninsula"
        else
            echo "Actualizacion peninsula fallida"
        fi
    else
        echo "No existe replica peninsula"
    fi
    if [ -d /db/diffs_can ] && [ -s /db/replicate_id_can ]; then
        echo "Actualiza Canarias"
        rm -rf /db/diffs
        rm -f /db/replicate_id
        cp  /db/replicate_id_can /db/replicate_id
        cp -r /db/diffs_can /db/diffs
        OVERPASS_DIFF_URL="${OVERPASS_DIFF_URL_CAN}" /app/bin/update_overpass.sh
        if [ -d /db/diffs ] && [ -s /db/replicate_id ]; then 
            rm -rf /db/diffs_can
            rm -f /db/replicate_id_can
            mv /db/replicate_id /db/replicate_id_can
            mv /db/diffs /db/diffs_can
            echo "Fin actualiza canarias"
        else
            echo "Actualizacion Canarias fallida"
        fi
    else
        echo "No existe replica Canarias"
    fi
    sleep "${OVERPASS_UPDATE_SLEEP}"
done

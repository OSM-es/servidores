#!/usr/bin/env sh

OVERPASS_UPDATE_SLEEP=${OVERPASS_UPDATE_SLEEP:-60}
OVERPASS_DIFF_URL_ESP=${OVERPASS_DIFF_URL_ESP:-http://download.openstreetmap.fr/replication/europe/spain/minute/}
OVERPASS_DIFF_URL_CAN=${OVERPASS_DIFF_URL_CAN:-https://download.geofabrik.de/africa/canary-islands-updates/}
set +e
while true; do
    echo "Actualiza península"
    [ -d /db/diffs_esp ] && mv /db/diffs_esp /db/diffs
    [ -s /db/replicate_id_esp ] && mv /db/replicate_id_esp /db/replicate_id
    OVERPASS_DIFF_URL="${OVERPASS_DIFF_URL_ESP}" /app/bin/update_overpass.sh
    [ -d /db/diffs ] && mv /db/diffs /db/diffs_esp
    [ -s /db/replicate_id ] && mv /db/replicate_id /db/replicate_id_esp
    echo "Actualiza Canarias"
    [ -d /db/diffs_can ] && mv /db/diffs_can /db/diffs
    [ -s /db/replicate_id_can ] && mv /db/replicate_id_can /db/replicate_id
    OVERPASS_DIFF_URL="${OVERPASS_DIFF_URL_CAN}" /app/bin/update_overpass.sh
    [ -d /db/diffs ] && mv /db/diffs /db/diffs_can
    [ -s /db/replicate_id ] && mv /db/replicate_id /db/replicate_id_can
    sleep "${OVERPASS_UPDATE_SLEEP}"
done

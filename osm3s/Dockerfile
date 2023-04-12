FROM wiktorn/overpass-api:0.7.56.9
LABEL maintainer="javiersanp@gmail.com"

COPY ./docker-healthcheck.sh /app/docker-healthcheck.sh
COPY ./update_overpass_loop.sh /app/bin/update_overpass_loop.sh
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./estado /app/cgi-bin/estado
RUN chmod +x /app/cgi-bin/estado

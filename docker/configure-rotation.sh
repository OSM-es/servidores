#!/bin/bash
set -e

# Logrotate for Docker container
# https://sandro-keil.de/blog/logrotate-for-docker-container/

cat > /etc/logrotate.d/docker-container << ENDOFFILE
/var/lib/docker/containers/*/*.log {
  rotate 7
  daily
  compress
  missingok
  delaycompress
  copytruncate
}
ENDOFFILE

logrotate -fv /etc/logrotate.d/docker-container

#!/bin/sh
set -e

. /init.sh
cat /etc/letsencrypt/live/docker.test/fullchain.pem
exec supercronic /opt/crontabs/root

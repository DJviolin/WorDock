#!/bin/sh
set -e

. /init.sh
exec supercronic /opt/crontabs/root

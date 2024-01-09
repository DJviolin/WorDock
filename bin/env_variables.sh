#!/bin/sh

set -e

# These are only used in shell scripts, don't need to export
# DIR=$(realpath -s $PWD/$(dirname $0))
DIR=$( cd "$(dirname $0)" && pwd )

export ABS_PATH=$( cd "$DIR/.." && pwd )

set -a && . $ABS_PATH/.env && set +a

PROJECT_HOST_DIR="$HOME/.$SERVER_NAME"
TIMESTAMP=$(date '+%s')_$(date '+%Y%m%d_%H%M%S')

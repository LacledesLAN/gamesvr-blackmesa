#!/bin/bash
set -euo pipefail

if (( $# != 1 )); then
    printf 'ERROR: Expected exactly one unqualified local image tag.\n' >&2
    exit 2
fi

image_tag="$1"
if [[ "$image_tag" != gamesvr-blackmesa && "$image_tag" != gamesvr-blackmesa:* ]]; then
    printf "ERROR: Invalid unqualified image tag for gamesvr-blackmesa: '%s'.\n" "$image_tag" >&2
    exit 2
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${script_dir}/tests/test-gamesvr-blackmesa.sh" "$image_tag" /app/srcds_run -game bms +map gasworks -insecure -maxplayers 8 -norestart +sv_lan 1
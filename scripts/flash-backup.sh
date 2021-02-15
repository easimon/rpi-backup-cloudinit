#!/bin/bash

set -euo pipefail

CALL_DIR="$(pwd)"
SCRIPT_DIR="$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
BASE_DIR="$(realpath "${SCRIPT_DIR}/..")"

# shellcheck source=scripts/config.sh
source "${SCRIPT_DIR}/config.sh"

function cleanup() {
  cd "${CALL_DIR}"
}

trap cleanup EXIT

${FLASH} \
   --metadata "$BASE_DIR/cloud-init/meta-data.yaml" \
   --userdata "$BASE_DIR/cloud-init/user-data.yaml" \
   "${BASE_DIR}/${IMAGE}"

#!/usr/bin/env bash

set -euo pipefail

case "$1" in
    azure) PKGNAME=khiops-driver-azure; DIRNAME=khiops_driver_azure;;
    gcs) PKGNAME=khiops-driver-gcs; DIRNAME=khiops_driver_gcs;;
    s3) PKGNAME=khiops-driver-s3; DIRNAME=khiops_driver_s3;;
    *) echo "Usage: $(basename "$0") {azure|gcs|s3}" >&2; exit 2;;
esac

while IFS='' read -r LINE; do
    if [[ "$LINE" =~ ^(.*)@@@(.+)@@@(.*)$ ]]; then
        echo "${BASH_REMATCH[1]}${!BASH_REMATCH[2]}${BASH_REMATCH[3]}"
    else
        echo "$LINE"
    fi
done
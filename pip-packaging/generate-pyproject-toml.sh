#!/usr/bin/env bash

# Script meant to generate driver-specific pyproject.toml file from the pyproject.toml.template file.
#
# One argument, which is mandatory, with available values: azure, gcs, s3.
#
# Replaces occurrences of @@@DRIVER@@@ found in standard input with the argument.
# Writes the resulting text to standard output.
#
# Supports only zero or one @@@...@@@ placeholder per input line.

set -euo pipefail

if [[ ! "$1" =~ ^(azure|gcs|s3)$ ]]; then
    echo "Usage: $(basename "$0") {azure|gcs|s3}" >&2
    exit 2
fi

DRIVER="$1"

while IFS='' read -r LINE; do
    if [[ "$LINE" =~ ^(.*)@@@(.+)@@@(.*)$ ]]; then
        echo "${BASH_REMATCH[1]}${!BASH_REMATCH[2]}${BASH_REMATCH[3]}"
    else
        echo "$LINE"
    fi
done
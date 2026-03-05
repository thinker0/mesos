#!/bin/bash
# Convert Mesos attribute string into individual files under /etc/mesos-agent/attributes/
# Usage: ./mesos-attributes-setup.sh [attribute_string]
#        or pipe: echo "group:aurora;server-group:shared" | ./mesos-attributes-setup.sh

set -euo pipefail

ATTRIBUTES_DIR="${ATTRIBUTES_DIR:-/etc/mesos-agent/attributes}"
ATTRIBUTE_STRING="${1:-}"

# Read from stdin if no argument given
if [[ -z "$ATTRIBUTE_STRING" ]]; then
    ATTRIBUTE_STRING="$(cat)"
fi

if [[ -z "$ATTRIBUTE_STRING" ]]; then
    echo "ERROR: No attribute string provided." >&2
    echo "Usage: $0 'group:aurora;server-group:shared;...'" >&2
    exit 1
fi

mkdir -p "$ATTRIBUTES_DIR"

IFS=';' read -ra PAIRS <<< "$ATTRIBUTE_STRING"

for pair in "${PAIRS[@]}"; do
    # Skip empty segments (e.g. from ';;')
    [[ -z "$pair" ]] && continue

    key="${pair%%:*}"
    value="${pair#*:}"

    # Skip if key is empty
    [[ -z "$key" ]] && continue

    echo "$value" > "${ATTRIBUTES_DIR}/${key}"
    echo "  ${ATTRIBUTES_DIR}/${key} <- '${value}'"
done

echo "Done. Attributes written to ${ATTRIBUTES_DIR}/"

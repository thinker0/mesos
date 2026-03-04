#!/bin/sh

# This script is used inside the Docker container to create a user and group
# that matches the host user running the RPM build, so that output files
# have the correct ownership upon completion.

USER_NAME=$1
USER_ID=$2
GROUP_NAME=$3
GROUP_ID=$4

if ! getent group "$GROUP_NAME" >/dev/null; then
  groupadd -g "$GROUP_ID" "$GROUP_NAME"
fi

if ! getent passwd "$USER_NAME" >/dev/null; then
  useradd -M -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$USER_NAME"
fi

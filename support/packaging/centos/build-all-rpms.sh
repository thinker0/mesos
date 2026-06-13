#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# This script builds RPM packages for CentOS 7, Rocky 8, and Rocky 9.
CENTOS_DIR="$(cd "$(dirname "$0")"; pwd -P)"

for distro in 7 8 9; do
  echo "============================================="
  echo "Building RPM for distro version: $distro"
  echo "============================================="
  CENTOS_DISTRO="$distro" "${CENTOS_DIR}/build-rpm-docker.sh"
done

echo "============================================="
echo "All RPMs have been built successfully!"
echo "============================================="

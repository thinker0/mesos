#!/bin/bash

# Build script for CMake-based RPM generation
set -e
set -o pipefail

CENTOS_VERSION=$(rpm --eval '%{centos_ver}')

export PACKAGING_DIR=$(readlink -e "$(dirname "$(dirname "$0")")")
export MESOS_DIR=$(readlink -e $PACKAGING_DIR/../../)

export BUILD_DIR="/tmp/mesos_build_centos${CENTOS_VERSION}"

echo "Building Mesos using CMake in ${BUILD_DIR}..."
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

if [ "$CENTOS_VERSION" -eq 7 ]; then
  source /opt/rh/devtoolset-7/enable
fi

# Run CMake to configure the project for RPM packaging
cmake "${MESOS_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCPACK_BINARY_RPM=ON \
  -DCPACK_RPM_PACKAGE_AUTOREQ="no" \
  -DUSE_STATIC_LIB=ON \
  -DCMAKE_INSTALL_PREFIX=/usr

# Build the project
cmake --build . --parallel 4

# Generate the RPM using CPack
cpack -G RPM

echo "CMake RPM build completed!"
mkdir -p "${MESOS_DIR}/centos${CENTOS_VERSION}/rpmbuild/RPMS/x86_64"
cp *.rpm "${MESOS_DIR}/centos${CENTOS_VERSION}/rpmbuild/RPMS/x86_64/"

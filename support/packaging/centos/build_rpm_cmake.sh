#!/bin/bash

# Build script for CMake-based RPM generation
set -e
set -o pipefail

CENTOS_VERSION=$(rpm --eval '%{centos_ver}')

export PACKAGING_DIR=$(readlink -e "$(dirname "$(dirname "$0")")")
export MESOS_DIR=$(readlink -e $PACKAGING_DIR/../../)

export BUILD_DIR="/tmp/mesos_build_centos${CENTOS_VERSION}"
export MAVEN_OPTS="-Dmaven.repo.local=${BUILD_DIR}/.m2/repository"

echo "Building Mesos using CMake in ${BUILD_DIR}..."
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

if [ "$CENTOS_VERSION" -eq 7 ]; then
  source /opt/rh/devtoolset-7/enable
fi

if [ "$CENTOS_VERSION" -eq 9 ]; then
  export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk"
  export PATH="${JAVA_HOME}/bin:${PATH}"
fi

# Run CMake to configure the project for RPM packaging
# BUILD_SHARED_LIBS=OFF forces static linking of 3rdparty libs (glog, grpc, protobuf, re2)
# so the resulting RPM has no external .so dependencies for those libraries.
cmake "${MESOS_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCPACK_BINARY_RPM=ON \
  -DCPACK_RPM_PACKAGE_AUTOREQ="no" \
  -DBUILD_SHARED_LIBS=OFF \
  -DENABLE_JAVA=ON \
  -DCMAKE_INSTALL_PREFIX=/usr

# Build the project (use 4 parallel jobs to avoid OOM killer)
cmake --build . --parallel 4

# Generate the RPM using CPack
cpack -G RPM

echo "CMake RPM build completed!"
mkdir -p "${MESOS_DIR}/centos${CENTOS_VERSION}/rpmbuild/RPMS/x86_64"
cp *.rpm "${MESOS_DIR}/centos${CENTOS_VERSION}/rpmbuild/RPMS/x86_64/"

FROM rockylinux:8
MAINTAINER Kapil Arya <kapil@apache.org>

# Enable powertools on Rocky 8 for devel packages and EPEL
RUN dnf install -y 'dnf-command(config-manager)' epel-release && \
    dnf config-manager --set-enabled powertools

# Get build tools
RUN dnf install -y --allowerasing \
      curl                      \
      git                       \
      redhat-rpm-config         \
      rpm-build                 \
      maven                     \
      make                      \
      gcc                       \
      gcc-c++                   \
      wget                      \
      tar

# Install modern CMake (3.20.0 or higher) for glog 0.6.2 and newer mesos dependencies
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then CMAKE_ARCH="x86_64"; else CMAKE_ARCH="aarch64"; fi && \
    wget -qO- "https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-${CMAKE_ARCH}.tar.gz" | tar --strip-components=1 -xz -C /usr/local

# Setup JDK
RUN dnf install -y java-1.8.0-openjdk-devel && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk' >> /etc/profile.d/java-home.sh

ADD mesos.spec /mesos.spec

RUN dnf makecache && \
    dnf builddep -y --define "MESOS_VERSION 1.0.0" --define "MESOS_RELEASE 1" /mesos.spec

ADD user-init.sh /user-init.sh

ARG USER_NAME=root
ARG USER_ID=0
ARG GROUP_NAME=root
ARG GROUP_ID=0

RUN /user-init.sh $USER_NAME $USER_ID $GROUP_NAME $GROUP_ID

FROM centos:7
MAINTAINER Kapil Arya <kapil@apache.org>

# Fix CentOS 7 EOL repositories
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org/centos/$releasever|baseurl=http://vault.centos.org/centos/7|g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org/altarch/$releasever|baseurl=http://vault.centos.org/altarch/7|g' /etc/yum.repos.d/CentOS-*

# Get curl.
RUN yum install -y epel-release centos-release-scl && \
    rm -f /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then CENTOS_URL_PREFIX="centos/7"; else CENTOS_URL_PREFIX="altarch/7"; fi && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-SCLo-*.repo && \
    sed -i 's|#baseurl|baseurl|g' /etc/yum.repos.d/CentOS-SCLo-*.repo && \
    sed -i "s|http://mirror.centos.org/centos/7|http://vault.centos.org/${CENTOS_URL_PREFIX}|g" /etc/yum.repos.d/CentOS-SCLo-*.repo && \
    yum install -y              \
      curl                      \
      git                       \
      redhat-rpm-config         \
      rpm-build                 \
      make                      \
      wget                      \
      devtoolset-7-gcc-c++

# Install modern CMake (3.20.0 or higher) for glog 0.6.2
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then CMAKE_ARCH="x86_64"; else CMAKE_ARCH="aarch64"; fi && \
    wget -qO- "https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-${CMAKE_ARCH}.tar.gz" | tar --strip-components=1 -xz -C /usr/local

# Setup JDK
RUN echo -e 'export JAVA_HOME=/usr/lib/jvm/java-openjdk' >> /etc/profile.d/java-home.sh

# Remove 'centos' from the rpm version string.
RUN sed -i -e's:.el7.centos:.el7:' /etc/rpm/macros.dist

ADD mesos.spec /mesos.spec

RUN yum makecache && \
    yum-builddep -y /mesos.spec

ADD user-init.sh /user-init.sh

ARG USER_NAME=root
ARG USER_ID=0
ARG GROUP_NAME=root
ARG GROUP_ID=0

RUN /user-init.sh $USER_NAME $USER_ID $GROUP_NAME $GROUP_ID

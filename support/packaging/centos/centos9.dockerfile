FROM rockylinux:9
MAINTAINER Kapil Arya <kapil@apache.org>

# Enable CRB for some devel packages and install EPEL
RUN dnf install -y epel-release && \
    dnf config-manager --set-enabled crb

# Get curl and build tools
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
      tar                       \
      cmake

# Setup JDK
RUN dnf install -y java-11-openjdk-devel && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' >> /etc/profile.d/java-home.sh

ADD mesos.spec /mesos.spec

RUN dnf makecache && \
    dnf builddep -y --define "MESOS_VERSION 1.0.0" --define "MESOS_RELEASE 1" /mesos.spec

ADD user-init.sh /user-init.sh

ARG USER_NAME=root
ARG USER_ID=0
ARG GROUP_NAME=root
ARG GROUP_ID=0

RUN /user-init.sh $USER_NAME $USER_ID $GROUP_NAME $GROUP_ID

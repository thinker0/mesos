%{!?MESOS_VERSION: %global MESOS_VERSION 1.0.0}
%{!?MESOS_RELEASE: %global MESOS_RELEASE 1}

Name:          mesos
Version:       %{MESOS_VERSION}
Release:       %{MESOS_RELEASE}%{?dist}
Summary:       Cluster manager for sharing distributed application frameworks
License:       ASL 2.0
URL:           http://mesos.apache.org/

ExclusiveArch: x86_64 aarch64

Source0:       %{name}-%{version}.tar.gz
Source1:       mesos-init-wrapper
Source2:       %{name}
Source3:       %{name}-master
Source4:       %{name}-agent

%if 0%{?el6}
Source5:       %{name}-master.upstart
Source6:       %{name}-agent.upstart
%endif

%if 0%{?el7}
Source5:       %{name}-master.service
Source6:       %{name}-agent.service
%endif

%if 0%{?el9} || 0%{?rhel} >= 8
BuildRequires: maven
BuildRequires: python3-devel
%else
BuildRequires: maven
BuildRequires: python-devel
%endif
BuildRequires: libtool
BuildRequires: automake
BuildRequires: java-1.8.0-openjdk-devel
BuildRequires: libnl3-devel
BuildRequires: zlib-devel
BuildRequires: libcurl-devel
BuildRequires: openssl-devel
BuildRequires: cyrus-sasl-devel
BuildRequires: cyrus-sasl-md5
BuildRequires: elfutils-libelf-devel
BuildRequires: libblkid-devel
BuildRequires: kernel-headers
BuildRequires: subversion-devel
BuildRequires: patch

%if 0%{?el6}
BuildRequires: devtoolset-7-gcc
BuildRequires: devtoolset-7-gcc-c++
BuildRequires: epel-rpm-macros
BuildRequires: libevent2-devel
%define _with_xfs no
%else
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: libevent-devel
BuildRequires: which
BuildRequires: xfsprogs-devel
%define _with_xfs yes
%endif

BuildRequires: apr-devel
BuildRequires: apr-util-devel

Requires: cyrus-sasl-md5
%{?el7:Requires: systemd}

Requires: ntp

# mesos bundles its own protobuf and installs /usr/bin/protoc, which file-conflicts
# with the OS protobuf-compiler package (e.g. protobuf-compiler-2.5.0-8.el7 on CentOS7),
# causing a yum transaction check error on install. Obsolete it so yum replaces
# protobuf-compiler with mesos on install instead of failing (no per-host manual removal).
Obsoletes: protobuf-compiler

%description
Apache Mesos is a cluster manager that provides efficient resource
isolation and sharing across distributed applications, or frameworks.
It can run Hadoop, MPI, Hypertable, Spark, and other applications on
a dynamically shared pool of nodes.

%package -n mesos-devel
Summary:	Mesos developer package
Group:		Development/Libraries
Requires:	mesos%{?_isa} = %{version}-%{release}

%description -n mesos-devel
This package provides files for developing Mesos frameworks/modules.

%prep
%setup -q

%build
%{!?el6:%define launcher_sealing --enable-launcher-sealing}

%configure \
    --enable-optimize \
    --disable-python-dependency-install \
%if 0%{?el9} || 0%{?rhel} >= 8
    --disable-python \
%endif
    --enable-install-module-dependencies \
    %{launcher_sealing} \
    --enable-libevent \
    --enable-ssl \
    --enable-hardening \
    --enable-xfs-disk-isolator=%{_with_xfs}

%make_build %{?_smp_mflags} V=0

%check

%install
%make_install

mkdir -p -m0755 %{buildroot}%{_sysconfdir}/default
mkdir -p -m0755 %{buildroot}%{_sysconfdir}/%{name}
mkdir -p -m0755 %{buildroot}%{_sysconfdir}/%{name}-master
mkdir -p -m0755 %{buildroot}%{_sysconfdir}/%{name}-agent
mkdir -p -m0755 %{buildroot}%{_sysconfdir}/%{name}-agent/attributes
mkdir -p -m0755 %{buildroot}%{_sysconfdir}/%{name}-agent/resources
mkdir -p -m0755 %{buildroot}/%{_var}/log/%{name}
mkdir -p -m0755 %{buildroot}/%{_var}/lib/%{name}

echo zk://localhost:2181/mesos > %{buildroot}%{_sysconfdir}/mesos/zk
echo %{_var}/lib/%{name}       > %{buildroot}%{_sysconfdir}/mesos-master/work_dir
echo %{_var}/lib/%{name}       > %{buildroot}%{_sysconfdir}/mesos-agent/work_dir
echo 1                         > %{buildroot}%{_sysconfdir}/mesos-master/quorum

install -m 0755 %{SOURCE1} %{buildroot}%{_bindir}/
install -m 0644 %{SOURCE2} %{SOURCE3} %{SOURCE4} %{buildroot}%{_sysconfdir}/default

%if 0%{?el6}
mkdir -p -m0755 %{buildroot}%{_sysconfdir}/init
install -m 0644 %{SOURCE5} %{buildroot}%{_sysconfdir}/init/mesos-master.conf
install -m 0644 %{SOURCE6} %{buildroot}%{_sysconfdir}/init/mesos-agent.conf
%endif

%if 0%{?el7}
mkdir -p -m0755 %{buildroot}%{_unitdir}/
install -m 0644 %{SOURCE5} %{SOURCE6} %{buildroot}%{_unitdir}
%endif

mkdir -p -m0755 %{buildroot}%{_datadir}/java
install -m 0644 src/java/target/mesos-*.jar %{buildroot}%{_datadir}/java/

%files
%doc LICENSE NOTICE
%{_libdir}/*.so
%{_libdir}/mesos/modules/*.so
%{_bindir}/mesos*
%{_sbindir}/mesos-*
%{_datadir}/%{name}/
%{_libexecdir}/%{name}/
%if 0%{?el9} || 0%{?rhel} >= 8
%else
%{python_sitelib}/%{name}*
%endif
%attr(0755,mesos,mesos) %{_var}/log/%{name}/
%attr(0755,mesos,mesos) %{_var}/lib/%{name}/
%config(noreplace) %{_sysconfdir}/%{name}*
%config(noreplace) %{_sysconfdir}/default/%{name}*

%if 0%{?el6}
%config(noreplace) %{_sysconfdir}/init/%{name}-*
%endif

%if 0%{?el7}
%{_unitdir}/%{name}*.service
%endif

%{_datadir}/java/%{name}-*.jar

######################
%files devel
%doc LICENSE NOTICE
%{_includedir}/csi/
%{_includedir}/elfio/
%{_includedir}/mesos/
%{_includedir}/stout/
%{_includedir}/process/
%{_includedir}/rapidjson/
%{_includedir}/picojson.h
%{_libdir}/pkgconfig/%{name}.pc
%{_libdir}/*.la
%{_libdir}/mesos/modules/*.la
%{_libdir}/mesos/3rdparty/

%pre

%post
/sbin/ldconfig
%if 0%{?el7}
%systemd_post %{name}-agent.service %{name}-master.service
%endif

%preun

%postun
/sbin/ldconfig

%changelog
* Mon Jan 16 2017 Kapil Arya <kapil@mesosphere.io> - 1.1.0-0.1
- Initial release

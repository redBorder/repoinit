%define __jar_repack 0
%define debug_package %{nil}
%define name         zookeeper
%define _prefix      /usr
%define _conf_dir    %{_sysconfdir}/zookeeper
%define _log_dir     %{_var}/log/zookeeper
%define _data_dir    %{_sharedstatedir}/zookeeper

Summary: ZooKeeper is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.
Name: zookeeper
Version: %{__version}
Release: %{__release}%{?dist}
License: Apache License, Version 2.0
Group: Applications/Databases
URL: http://zookeper.apache.org/
Source0: zookeeper-%{version}.tar.gz
Source1: zookeeper.service
Source2: zookeeper.logrotate
Source3: zoo.cfg
Source4: log4j.properties
Source5: log4j-cli.properties
Source6: zookeeper.sysconfig
Source7: zkcli
Source8: zookeeper.sh
Prefix: %{_prefix}
Vendor: Apache Software Foundation
Packager: Juan J. Prieto <jjprieto@redborder.com>
Provides: zookeeper
BuildRequires: systemd autoconf libtool
Requires: libzookeeper java
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd

%description
ZooKeeper is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services. All of these kinds of services are used in some form or another by distributed applications. Each time they are implemented there is a lot of work that goes into fixing the bugs and race conditions that are inevitable. Because of the difficulty of implementing these kinds of services, applications initially usually skimp on them ,which make them brittle in the presence of change and difficult to manage. Even when done correctly, different implementations of these services lead to management complexity when the applications are deployed.

%prep
%setup -q -n zookeeper-%{version}

%build
pushd src/c
%configure
%{__make} %{?_smp_mflags}
popd


%install
mkdir -p $RPM_BUILD_ROOT%{_prefix}/lib/zookeeper
mkdir -p $RPM_BUILD_ROOT%{_log_dir}
mkdir -p $RPM_BUILD_ROOT%{_data_dir}
mkdir -p $RPM_BUILD_ROOT%{_unitdir}/zookeeper.service.d
mkdir -p $RPM_BUILD_ROOT%{_conf_dir}/
mkdir -p $RPM_BUILD_ROOT/etc/profile.d
install -p -D -m 644 zookeeper-%{version}.jar $RPM_BUILD_ROOT%{_prefix}/lib/zookeeper/
install -p -D -m 644 lib/*.jar $RPM_BUILD_ROOT%{_prefix}/lib/zookeeper/
install -p -D -m 755 %{S:1} $RPM_BUILD_ROOT%{_unitdir}/
install -p -D -m 644 %{S:2} $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/zookeeper
install -p -D -m 644 %{S:3} $RPM_BUILD_ROOT%{_conf_dir}/
install -p -D -m 644 %{S:4} $RPM_BUILD_ROOT%{_conf_dir}/
install -p -D -m 644 %{S:5} $RPM_BUILD_ROOT%{_conf_dir}/
install -p -D -m 644 %{S:6} $RPM_BUILD_ROOT%{_sysconfdir}/sysconfig/zookeeper
install -p -D -m 755 %{S:7} $RPM_BUILD_ROOT%{_prefix}/bin/zkcli
install -p -D -m 644 conf/configuration.xsl $RPM_BUILD_ROOT%{_conf_dir}/
install -p -D -m 755 bin/*.sh $RPM_BUILD_ROOT%{_prefix}/bin
install -p -D -m 644 %{S:8} $RPM_BUILD_ROOT/etc/profile.d

# stupid systemd fails to expand file paths in runtime
CLASSPATH=
for i in $RPM_BUILD_ROOT%{_prefix}/lib/zookeeper/*.jar
do
  CLASSPATH="%{_prefix}/lib/zookeeper/$(basename ${i}):${CLASSPATH}"
done
echo "[Service]" > $RPM_BUILD_ROOT%{_unitdir}/zookeeper.service.d/classpath.conf
echo "Environment=CLASSPATH=${CLASSPATH}" >> $RPM_BUILD_ROOT%{_unitdir}/zookeeper.service.d/classpath.conf
echo "" >> $RPM_BUILD_ROOT%{_prefix}/bin/zkEnv.sh
echo "CLASSPATH=\$CLASSPATH:${CLASSPATH}" >> $RPM_BUILD_ROOT%{_prefix}/bin/zkEnv.sh

%{makeinstall} -C src/c

%clean
rm -rf $RPM_BUILD_ROOT

%pre
/usr/bin/getent group zookeeper >/dev/null || /usr/sbin/groupadd -r zookeeper
if ! /usr/bin/getent passwd zookeeper >/dev/null ; then
    /usr/sbin/useradd -r -g zookeeper -d %{_prefix}/lib/zookeeper -s /sbin/nologin -c "Zookeeper" zookeeper
fi

%post
%systemd_post zookeeper.service

%preun
%systemd_preun zookeeper.service

%postun
# When the last version of a package is erased, $1 is 0
# Otherwise it's an upgrade and we need to restart the service
if [ $1 -ge 1 ]; then
    /usr/bin/systemctl restart zookeeper.service
fi
/usr/bin/systemctl daemon-reload >/dev/null 2>&1 || :

%files
%defattr(-,root,root)
%{_unitdir}/zookeeper.service
%{_unitdir}/zookeeper.service.d/classpath.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/zookeeper
%config(noreplace) %{_sysconfdir}/sysconfig/zookeeper
%config(noreplace) %{_conf_dir}/*
%defattr(0755,root,root)
%{_prefix}/bin/cli_mt
%{_prefix}/bin/cli_st
%{_prefix}/bin/load_gen
%{_prefix}/bin/zkCleanup.sh
%{_prefix}/bin/zkCli.sh
%{_prefix}/bin/zkEnv.sh
%{_prefix}/bin/zkServer.sh
%{_prefix}/bin/zkcli
/etc/profile.d/zookeeper.sh
%attr(-,zookeeper,zookeeper) %{_prefix}/lib/zookeeper
%attr(0755,zookeeper,zookeeper) %dir %{_log_dir}
%attr(0700,zookeeper,zookeeper) %dir %{_data_dir}

# ------------------------------ libzookeeper ------------------------------

%package -n libzookeeper
Summary: C client interface to zookeeper server
Group: Development/Libraries
BuildRequires: gcc

%description -n libzookeeper
The client supports two types of APIs -- synchronous and asynchronous.
 
Asynchronous API provides non-blocking operations with completion callbacks and
relies on the application to implement event multiplexing on its behalf.
 
On the other hand, Synchronous API provides a blocking flavor of
zookeeper operations and runs its own event loop in a separate thread.
 
Sync and Async APIs can be mixed and matched within the same application.

%files -n libzookeeper
%defattr(-, root, root, -)
%doc src/c/README src/c/LICENSE
%{_libdir}/libzookeeper_mt.so.*
%{_libdir}/libzookeeper_st.so.*

# ------------------------------ libzookeeper-devel ------------------------------

%package -n libzookeeper-devel
Summary: Headers and static libraries for libzookeeper
Group: Development/Libraries
BuildRequires: gcc
Requires: libzookeeper

%description -n libzookeeper-devel
This package contains the libraries and header files needed for
developing with libzookeeper.

%files -n libzookeeper-devel
%defattr(-, root, root, -)
%{_includedir}
%{_libdir}/*.a
%{_libdir}/*.la
%{_libdir}/*.so

%pre -n libzookeeper-devel
getent group zookeeper >/dev/null || groupadd -r zookeeper
getent passwd zookeeper >/dev/null || useradd -r -g zookeeper -d / -s /sbin/nologin zookeeper
exit 0

%post -n libzookeeper-devel
/sbin/chkconfig --add zookeeper

%preun -n libzookeeper-devel
if [ $1 = 0 ] ; then
    /sbin/service zookeeper stop >/dev/null 2>&1
    /sbin/chkconfig --del zookeeper
fi

%postun -n libzookeeper-devel
if [ "$1" -ge "1" ] ; then
    /sbin/service zookeeper condrestart >/dev/null 2>&1 || :
fi

%changelog
* Tue Jun 14 2016 Juan J. Prieto <jjprieto@redborder.com> - 3.4.8-1
- Fisrt version for 3.4.8





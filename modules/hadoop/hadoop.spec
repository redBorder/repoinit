Name: hadoop
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for apache hadoop

Group: System Environment/Base
License: Apache License
URL: http://apache.rediris.es/hadoop
Source0: %{name}-%{version}.tar.gz
Source1: hadoop-resourcemanager.service
Source2: hadoop-nodemanager.service
Source3: java
Source4: hadoop_resourcemanager
Source5: hadoop_nodemanager

Requires: java-1.8.0-openjdk

%description

%prep
%setup -qn %{name}-%{version}

%build

%pre
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -d /var/lib/%{name} -s /bin/bash \
    -c "User for Hadoop" %{name} -m
exit 0

%install
mkdir -p %{buildroot}/usr/lib/hadoop
cp -rf * %{buildroot}/usr/lib/hadoop/
install -D -m 644 %{SOURCE1} %{buildroot}/usr/lib/systemd/system/hadoop-resourcemanager.service
install -D -m 644 %{SOURCE2} %{buildroot}/usr/lib/systemd/system/hadoop-nodemanager.service
[ -f /etc/sysconfig/java ] || install -D -m 644 %{SOURCE3} %{buildroot}/etc/sysconfig/java
[ -f /etc/sysconfig/hadoop_resourcemanager ] || install -D -m 644 %{SOURCE4} %{buildroot}/etc/sysconfig/hadoop_resourcemanager
[ -f /etc/sysconfig/hadoop_nodemanager ] || install -D -m 644 %{SOURCE5} %{buildroot}/etc/sysconfig/hadoop_nodemanager

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
/usr/lib/hadoop
%defattr(644,root,root)
/usr/lib/systemd/system/hadoop-resourcemanager.service
/usr/lib/systemd/system/hadoop-nodemanager.service
%defattr(644, root,root)
%config /etc/sysconfig/java
%config /etc/sysconfig/hadoop_resourcemanager
%config /etc/sysconfig/hadoop_nodemanager
%defattr(-,hadoop,hadoop)
%ghost /var/lib/hadoop

%changelog
* Mon Nov 14 2016 Alberto Rodriguez <arodriguez@redborder.com> - 2.7.3-1
- first spec version
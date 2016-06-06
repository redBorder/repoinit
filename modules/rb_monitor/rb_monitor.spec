%global gh_commit    89fe893f63d4ce0f5fc32c3f8dab75fa94497d08
%global gh_short     %(c=%{gh_commit}; echo ${c:0:7})
%global gh_owner     redBorder
%global gh_project   rb_monitor

Name:    rb_monitor
Summary: Get data events via SNMP or scripting and send results in json over kafka.
Version: %{__version}
Release: %{__release}%{?dist}
Commit: %{gh_commit}

License: GNU AGPLv3
URL: https://github.com/redBorder/rb_monitor/archive/${gh_commit}/${gh_project}-${version}-${gh_short}.tar.gz
Source0: %{gh_project}-%{version}.tar.gz

Patch010:       010-r_monitor-1.0-configfile.patch
Patch020:       020-r_monitor-1.0-initscript.patch

BuildRequires: gcc librd-devel net-snmp-devel json-c-devel librdkafka-devel libmatheval-devel libpcap-devel

Summary: Non-blocking high-level wrapper for libcurl
Group:   Development/Libraries/C and C++
Requires: librd
%description
%{summary}

%prep
%setup -qn redBorder-monitor-redborder-%{gh_commit}
%patch010 -p1
%patch020 -p1

%build
./configure --prefix=/opt/rb
make

%install
DESTDIR=%{buildroot} make install
mkdir -p %{buildroot}/etc/init
cp rb-monitor.init %{buildroot}/etc/init/rb-monitor.conf
mkdir -p %{buildroot}/opt/rb/etc/rb-monitor
cp config.json %{buildroot}/opt/rb/etc/rb-monitor

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%defattr(755,root,root)
/opt/rb/bin/rb_monitor
%defattr(644,root,root)
/opt/rb/etc/rb-monitor/config.json
/etc/init/rb-monitor.conf

%changelog
* Wed May 11 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.0-1
- first spec version



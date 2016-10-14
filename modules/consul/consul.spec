Name: consul
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for consul, a service discovery and configuration solution

Group: System Environment/Base
License: GPLv2
URL: https://github.com/hashicorp/consul
Source0: consul
Source1: consul.service

%description
Consul is a tool for service discovery and configuration. Consul is distributed, highly available, and extremely scalable.

%prep

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -D -m 755 %{SOURCE0} %{buildroot}%{_bindir}
install -D -m 644 %{SOURCE1} %{buildroot}/usr/lib/systemd/system/consul.service

%clean
rm -rf %{buildroot}

%files
%defattr(0755,root,root)
%{_bindir}/consul
%defattr(644,root,root)
/usr/lib/systemd/system/consul.service

%changelog
* Tue Oct 11 2016 Alberto Rodriguez <arodriguez@redborder.com> - 0.7.0-2
- add unit file for systemd service management
* Fri Sep 16 2016 Alberto Rodriguez <arodriguez@redborder.com> - 0.7.0-1
- first spec version

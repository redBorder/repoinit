Name: consul
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for consul, a service discovery and configuration solution

Group: System Environment/Base
License: GPLv2
URL: https://github.com/hashicorp/consul
Source0: consul

%description
Consul is a tool for service discovery and configuration. Consul is distributed, highly available, and extremely scalable.

%prep

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -D -m 755 %{SOURCE0} %{buildroot}%{_bindir}

%files
%defattr(0755,root,root)
%{_bindir}/consul

%changelog
* Fri Sep 16 2016 Alberto Rodriguez <arodriguez@redborder.com> - 0.7.0-1
- first spec version

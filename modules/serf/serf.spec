Name: serf
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for serf, a service discovery and orchestation solution

Group: System Environment/Base
License: GPLv2
URL: https://github.com/hashicorp/serf
Source0: serf

%description
Serf is a decentralized solution for service discovery and orchestration that is lightweight,
highly available, and fault tolerant.

%prep

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -D -m 755 %{SOURCE0} %{buildroot}%{_bindir}

%files
%defattr(0755,root,root)
%{_bindir}/serf

%changelog
* Thu Jul 07 2016 Juan J. Prieto <jjprieto@redborder.com> - 0.7.0-1
- first spec version

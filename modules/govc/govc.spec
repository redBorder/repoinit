Name: govc
Version: %{__version}
Release: %{__release}%{?dist}
Summary: vSphere CLI built on top of govmomi

Group: System Environment/Base
License: MIT
URL: https://github.com/vmware/govmomi
Source0: govc

%description
govc is a vSphere CLI built on top of govmomi.

%prep

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -D -m 755 %{SOURCE0} %{buildroot}%{_bindir}/govc

%files
%defattr(0755,root,root)
%{_bindir}/govc

%changelog
* Wed Jun 24 2026 Nils <nverschaeve@redborder.com> - 0.0.1-1
- first spec version

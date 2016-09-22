Name: docker-repo
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for docker official repository
BuildArch: noarch

Group: System Environment/Base
License: GPLv2
URL: https://yum.dockerproject.org/repo/main/centos/7/
Source0: docker.repo

%description
This package contains yum configuration to add docker official repository.

%prep

%build

%install
mkdir -p $RPM_BUILD_ROOT/etc/yum.repos.d
install -D -m 644 %{SOURCE0} $RPM_BUILD_ROOT/etc/yum.repos.d/

%files
%defattr(0644,root,root)
/etc/yum.repos.d/docker.repo

%changelog
* Thu Sep 22 2016 Alberto Rodriguez <arodriguez@redborder.com> - 1.0.0-1
- first spec version

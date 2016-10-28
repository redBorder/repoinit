Name: rbrepo-devel	
Version: 1.0.0	
Release: 1%{?dist}
Summary: package for redborder devel repository	
BuildArch: noarch

Group: System Environment/Base
License: GPLv2
URL: http://rbrepo.redborder.lan/devel	
Source0: rbrepo-devel.repo
Requires: epel-release

%description
This package contains the Extra Packages for redborder devel repository
as well as configuration for yum.

%prep

%build

%install
mkdir -p $RPM_BUILD_ROOT/etc/yum.repos.d
install -D -m 644 %{SOURCE0} $RPM_BUILD_ROOT/etc/yum.repos.d/

%files
%defattr(0644,root,root)
/etc/yum.repos.d/rbrepo-devel.repo

%changelog
* Fri Oct 28 2016 Carlos J. Mateos <cjmateos@redborder.com> - 1.0.0-1
- first spec version

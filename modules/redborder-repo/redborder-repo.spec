Name: redborder-repo
Version: %{__version}	
Release: %{__release}%{?dist}
Summary: package for redborder repository	
BuildArch: noarch

Group: System Environment/Base
License: GPLv2
URL: http://rbrepo.redborder.lan/redBorder	
Source0: redborder.repo
Requires: epel-release

%description
This package contains the Extra Packages for redBorder repository
as well as configuration for yum.

%prep

%build

%install
mkdir -p $RPM_BUILD_ROOT/etc/yum.repos.d
install -D -m 644 %{SOURCE0} $RPM_BUILD_ROOT/etc/yum.repos.d/

%files
%defattr(0644,root,root)
/etc/yum.repos.d/redborder.repo

%changelog
* Thu Jun 02 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.0.0-1
- first spec version

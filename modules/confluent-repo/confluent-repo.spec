Name: confluent-repo
Version: 1.0.0	
Release: 1%{?dist}
Summary: package for Confluent repository	
BuildArch: noarch

Group: System Environment/Base
License: GPLv2
Source0: confluent-repo.repo
Requires: epel-release crypto-policies-scripts
BuildRequires: crypto-policies-scripts

%description
This package contains the Extra Packages for Confluent repository
as well as configuration for yum.

%prep
update-crypto-policies --set DEFAULT:SHA1

%build
rpm --import http://packages.confluent.io/rpm/3.0/archive.key

%install
mkdir -p $RPM_BUILD_ROOT/etc/yum.repos.d
install -D -m 644 %{SOURCE0} $RPM_BUILD_ROOT/etc/yum.repos.d/

%files
%defattr(0644,root,root)
/etc/yum.repos.d/confluent-repo.repo

%changelog
* Thu Jun 23 2016 Carlos J. Mateos <cjmateos@redborder.com> - 1.0.0-1
- first spec version

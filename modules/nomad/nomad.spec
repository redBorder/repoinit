Name: nomad
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for nomad. A Distributed, Highly Available, Datacenter-Aware Scheduler 

Group: System Environment/Base
License: GPLv2
URL: https://github.com/hashicorp/nomad 
Source0: nomad

%description
Nomad is a tool for managing a cluster of machines and running applications on them. Nomad abstracts away machines and the location of applications, and instead enables users to declare what they want to run and Nomad handles where they should run and how to run them.

%prep

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -D -m 755 %{SOURCE0} %{buildroot}%{_bindir}

%files
%defattr(0755,root,root)
%{_bindir}/nomad

%changelog
* Fri Aug 26 2016 Carlos J. Mateos <cjmateos@redborder.com> - 0.4.1-1
- first spec version

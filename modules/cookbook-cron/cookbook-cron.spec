Name: cookbook-cron
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: cron cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/chef-cookbooks/cron
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn cron-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/cron
cp -f -r  * %{buildroot}/var/chef/cookbooks/cron/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/cron
#install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/cron/README.md

%pre

%post

%files
%defattr(0755,root,root)
/var/chef/cookbooks/cron

%doc

%changelog
* Tue Oct 18 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.0.0-1
- first spec version

%define debug_package %{nil}
%global rvm_dir /usr/lib/rvm
%global rvm_group rvm
%global ruby_version %{__rubyversion}
%global bundler_version %{__bundlerversion}
%global rubygems_version %{__rubygemsversion}

Name: rvm
Version: %{__version}
Release: %{__release}%{?dist}
License: ASL 2.0
BuildArch: x86_64
#Source: ruby-%{ruby_version}.tar.bz2
Source0: rvm-%{version}.tar.gz
Source1: bundler-1.12.5.gem
Source2: bundle-0.0.1.gem
Source3: system-getifaddrs-0.2.1.gem
Source4: getopt-1.4.3.gem
Source5: prettyprint-0.0.1.gem
Source6: netaddr-1.5.1.gem
Source7: json-1.8.3.gem
Source8: thread_safe-0.3.5.gem
Source9: descendants_tracker-0.0.4.gem
Source10: coercible-1.0.0.gem
Source11: symmetric-encryption-3.8.3.gem
Source12: arp_scan-0.1.0.gem
Source13: knife-acl-0.0.12.gem

BuildRequires: libyaml-devel libffi-devel autoconf automake libtool bison
BuildRequires: gcc-c++ patch readline readline-devel zlib-devel openssl-devel procps-ng sqlite-devel
#BuildRequires: patch readline procps-ng 
Requires: sed grep tar gzip bzip2 make file
Summary: Rvm and ruby

%description
Rvm with ruby, gem, and bundler, packaged as an rpm. System level install.
Versions: ruby-%{ruby_version}, bundler-%{bundler_version} and 
rubygems-%{rubygems_version}

%prep
%setup -q -n rvm-%{version}

%build
rvm_path="%{rvm_dir}" \
  rvm_man_path="%{_mandir}" \
  ./install --auto-dotfiles &>/dev/null

echo "" > %{rvm_dir}/gemsets/default.gems
echo "" > %{rvm_dir}/gemsets/global.gems

echo "
umask u=rwx,g=rwx,o=rx
rvm_path="%{rvm_dir}"
rvm_archives_path=%{rvm_dir}/archives
rvm_autolibs_flag=read-fail
" > /etc/rvmrc

cp -rf $RPM_SOURCE_DIR/* %{rvm_dir}/archives/
chgrp -R rvm %{rvm_dir}
chmod -R g+wxr %{rvm_dir}

%{rvm_dir}/bin/rvm install %{ruby_version}

echo "
current=ruby-%{ruby_version}
default=ruby-%{ruby_version}
" > %{rvm_dir}/config/alias

# install bundle gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundler-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundle-*.gem

# install global basic gems
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/prettyprint-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/getopt-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/netaddr-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/system-getifaddrs-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/json-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/thread_safe-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/descendants_tracker-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/coercible-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/symmetric-encryption-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/arp_scan-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/knife-acl-*.gem

rm -rf %{rvm_dir}/src/*
rm -rf %{rvm_dir}/log/*
rm -rf %{rvm_dir}/archives/*

%install
rm -rf $RPM_BUILD_ROOT/*
mkdir -p $RPM_BUILD_ROOT/%{rvm_dir}
mkdir -p $RPM_BUILD_ROOT/etc
mkdir -p $RPM_BUILD_ROOT/etc/profile.d

cp -rf %{rvm_dir}/* $RPM_BUILD_ROOT/%{rvm_dir}/
cp /etc/profile.d/rvm.sh $RPM_BUILD_ROOT/etc/profile.d/rvm.sh
cp /etc/rvmrc $RPM_BUILD_ROOT/etc/rvmrc

chgrp -R rvm $RPM_BUILD_ROOT/%{rvm_dir}
chmod -R g+wxr $RPM_BUILD_ROOT/%{rvm_dir}

%clean

%pre
getent group rvm >/dev/null || groupadd -r rvm

%post
/bin/bash --login -c "rvm use %{ruby_version} --default" || :

%files
%{rvm_dir}
/etc/rvmrc
/etc/profile.d/rvm.sh

%changelog
* Fri Jun 17 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.27.0
- Updated to latest version


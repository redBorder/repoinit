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
Source0: rvm-%{version}.tar.gz
#Source1: ruby-%{ruby_version}.tar.bz2
#Source2: bundler-%{bundler_version}.gem
#Source3: rubygems-%{rubygems_version}.tar.gz
#Source4: bundle-0.0.1.gem
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

#%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundle-0.0.1.gem
#%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundler-%{bundler_version}.gem

%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install bundle

##%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundler-1.7.3.gem

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


%global rvm_dir /usr/lib/rvm
%global rvm_group rvm
%global ruby_version 2.2.4

Name: rvm
Version: 1.27.0
Release: 1%{?dist}
License: ASL 2.0
Source0: rvm-%{version}.tar.gz
BuildRequires: libyaml-devel libffi-devel autoconf automake libtool bison
BuildRequires: gcc-c++ patch readline readline-devel zlib-devel openssl-devel procps-ng sqlite-devel
Requires: sed grep tar gzip bzip2 make file
Summary: Rvm and ruby

%description
Rvm with ruby, gem, and bundler, packaged as an rpm. System level install.

%prep
%setup -q -n rvm-%{version}

%build
rvm_path="%{rvm_dir}" \
  rvm_man_path="%{_mandir}" \
  ./install --auto-dotfiles &>/dev/null

#mkdir -p $RPM_BUILD_ROOT/rvm
#cp $RPM_SOURCE_DIR/rvm/rvm-stable.tar.gz $RPM_BUILD_ROOT/
#cd $RPM_BUILD_ROOT/rvm
#tar --strip-components=1 -xzf ../rvm-stable.tar.gz
#sudo ./install --auto-dotfiles

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

#%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundler-1.7.3.gem

rm -rf %{rvm_dir}/src/*

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
#sudo rm -rf /usr/local/rvm
#sudo rm /etc/rvmrc
#sudo rm /etc/profile.d/rvm.sh

%files
%{rvm_dir}
/etc/rvmrc
/etc/profile.d/rvm.sh

%changelog
* Fri Jun 17 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.27.0
- Updated to latest version


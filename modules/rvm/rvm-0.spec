%global rvm_version_sha1 1d4af11
%global rvm_dir /usr/lib/rvm
%global rvm_group rvm

Name: rvm
Summary: Ruby Version Manager
Version: 1.27.0
Release: 1%{?dist}
License: ASL 2.0
URL: http://rvm.beginrescueend.com/
Group: Applications/System
# Downloaded with
# wget --no-check-certificate http://github.com/wayneeseguin/rvm/tarball/<version>
Source0: rvm-%{version}.tar.gz
Source1: rvm.sh
Source2: rvmrc
BuildArch: noarch
#BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Requires(pre): shadow-utils
# For rvm
Requires: bash curl
# Basics for building ruby 1.8/1.9
BuildRequires: gcc-c++ patch readline readline-devel zlib-devel libyaml-devel libffi-devel openssl-devel less procps-ng autoconf automake libtool bison sqlite-devel
# Used by the scripts
Requires: sed grep tar gzip bzip2 make file procps-ng

%description
RVM is the Ruby Version Manager (rvm). It manages Ruby interpreter environments
and switching between them.

This package is meant for use by multiple users maintaining a shared copy of
RVM. Users added to the '%{rvm_group}' group will be able to modify all aspects
of RVM. These users will also have their default umask modified ("g+w") to allow
group write permission (usually resulting in a umask of "0002") in order to
ensure correct permissions for the shared RVM content.

RVM is activated for all logins by default. To disable remove 
%{_sysconfdir}/profile.d/rvm.sh and source rvm from each users shell.

%prep
%setup -q -n rvm-%{version}

%build

# Clean the env
#for i in `env | grep ^rvm_ | cut -d"=" -f1`; do 
#  unset $i;
#done

# Install everything into one directory
#rvm_ignore_rvmrc=0 \
#  rvm_user_install_flag=1 \
#  rvm_path="%{buildroot}%{rvm_dir}" \
#  rvm_bin_path="%{buildroot}%{_bindir}" \
#  rvm_man_path="%{buildroot}%{_mandir}" \
#  ./install --auto-dotfiles &>/dev/null

rvm_ignore_rvmrc=0 \
  rvm_user_install_flag=1 \
  rvm_path="%{rvm_dir}" \
  rvm_man_path="%{_mandir}" \
  ./install --auto-dotfiles &>/dev/null

/usr/lib/rvm/bin/rvm install 2.2

%install

rm -rf %{buildroot}

# So members of the rvm group can write to it
find %{buildroot}%{rvm_dir} -exec chmod ug+w {} \;
find %{buildroot}%{rvm_dir} -type d -exec chmod g+s {} \;

mkdir -p %{buildroot}%{_sysconfdir}
mkdir -p %{buildroot}%{_sysconfdir}/profile.d

install -m 755 %{S:1} %{buildroot}%{_sysconfdir}/profile.d/rvm.sh
install -m 755 %{S:2} %{buildroot}%{_sysconfdir}/rvmrc

#chmod 755 %{buildroot}%{_sysconfdir}/profile.d/rvm.sh


%clean
#rm -rf %{buildroot}

%pre
getent group %{rvm_group} >/dev/null || groupadd -r %{rvm_group}
exit 0

%post
grep -q "^type rvm" /etc/bash.bashrc 2>/dev/null || \
	echo 'type rvm >/dev/null 2>/dev/null || echo ${PATH} | __rvm_grep "/usr/lib/rvm/bin" > /dev/null || export PATH="${PATH}:/usr/lib/rvm/bin\"' >> /etc/bash.bashrc

source /etc/profile || :

%files
%defattr(-,root,root)
%config(noreplace) /etc/rvmrc
%config(noreplace) /etc/profile.d/rvm.sh
%attr(-,root,%{rvm_group}) %{rvm_dir}
%{_mandir}/man1/*
#%{_bindir}/rvm*
#/usr/bin/ruby-rvm-env

%changelog
* Fri Jun 17 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.27.0
- Updated to latest version

* Tue Dec 13 2011 Matthew Kent <mkent@magoazul.com> - 1.10.0-2
- New upstream release
- Drop rvm_prefix
- Rename rvm_user_install to rvm_user_install_flag
- Rename rake wrapper to rvm-rake
- Add file dependency

* Thu Aug 4 2011 Matthew Kent <mkent@magoazul.com> - 1.6.32-1
- New upstream release

* Tue Apr 19 2011 Matthew Kent <mkent@magoazul.com> - 1.6.3-1
- Initial package based off Gentoo work


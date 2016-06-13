# vim: set ts=4 sw=4 et:

Name:           xml-coreutils
Version:        %{__version}
Release:        %{__release}%{?dist}
Summary:        Command Line Tools for Reading and Writing XML Files
# http://prdownloads.sourceforge.net/xml-coreutils/xml-coreutils-%{version}.tar.gz
Source:         %{name}-%{version}.tar.gz
# various fixes taken from https://github.com/rudimeier/xml-coreutils/
Patch1:         %{name}-github-rudimeier-v0.8.1-18-g9a5e6d9.patch
# autoreconf after all other patches were applied
Patch2:         %{name}-autoreconf.patch
URL:            http://xml-coreutils.sourceforge.net/
Group:          Productivity/Text/Utilities
License:        GNU General Public License version 3 (GPL v3)
BuildRoot:      %{_tmppath}/build-%{name}-%{version}
BuildRequires:  expat expat-devel
BuildRequires:  gcc make glibc-devel pkgconfig
BuildRequires:  slang-devel

%description
The xml-coreutils are a set of command line tools for reading and writing XML
files in a Unix/POSIX type shell environment. The tools try to be as close as
possible to the traditional text processing tools... cat, echo, sed, etc

%prep
%setup -q
%patch1 -p1
%patch2 -p1

%build
export CPPFLAGS="%{optflags} -I/usr/include/slang"
%configure
%__make %{?_smp_mflags}

%install
%{?make_install} %{!?make_install:make install DESTDIR=%{buildroot}}
%__rm -rf "%{buildroot}%{_datadir}/xml-coreutils"

%__rm doc/Makefile*

%check
%__make -C src check

%clean
%{?buildroot:%__rm -rf "%{buildroot}"}

%files
%defattr(-,root,root)
%doc ChangeLog COPYING NEWS README SFX THANKS
%doc doc/*
%{_bindir}/xml-awk
%{_bindir}/xml-cat
%{_bindir}/xml-cp
%{_bindir}/xml-cut
%{_bindir}/xml-echo
%{_bindir}/xml-file
%{_bindir}/xml-find
%{_bindir}/xml-fixtags
%{_bindir}/xml-fmt
%{_bindir}/xml-grep
%{_bindir}/xml-head
%{_bindir}/xml-less
%{_bindir}/xml-ls
%{_bindir}/xml-mv
%{_bindir}/xml-printf
%{_bindir}/xml-paste
%{_bindir}/xml-rm
%{_bindir}/xml-sed
%{_bindir}/xml-strings
%{_bindir}/xml-unecho
%{_bindir}/xml-wc
%doc %{_mandir}/man1/xml-*.1*
%doc %{_mandir}/man7/xml-coreutils.7*

%changelog
* Mon Jun 13 2016 jjprieto@redborder.com
- Adapted to redborder framework

* Thu Nov 15 2012 sweet_f_a@gmx.de
- add xml-coreutils-github-rudimeier-v0.8.1-18-g9a5e6d9.patch
  from https://github.com/rudimeier/xml-coreutils which fixes many
  build issues
- remove useless build deps
- don't use deprecated makeinstall macro
* Sat Apr 16 2011 pascal.bleser@opensuse.org
- update to 0.8.1:
  * add new xml-paste
* Mon May 17 2010 pascal.bleser@opensuse.org
- initial package

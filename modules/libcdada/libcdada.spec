%define sover 0
Name:           libcdada
Version:        %{__version}
Release:        %{__release}%{?dist}
Summary:        Basic data structures in C (libstdc++ wrapper)
License:        BSD-2-Clause
Group:          Development/Languages/C and C++
URL:            https://msune.github.io/libcdada/
#Git-Clone:     https://github.com/msune/libcdada.git
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  gcc-c++
BuildRequires:  libtool
BuildRequires:  python3
BuildRequires:  valgrind

%description
Library that offers basic data structures (list, set, map, ..)
in a C API for user-space applications.

Key features:
 - No "magic" MACROs, and no need to modify data structures
   (except, perhaps, for __attribute__((packed)))
 - Uses C++ standard library as the backend for most data structures

%package -n libcdada%{sover}
Summary:        Basic data structures in C (libstdc++ wrapper)
Group:          System/Libraries

%description -n libcdada%{sover}
Library that offers basic data structures (list, set, map, ..)
in a C API for user-space applications.

Key features:
 - No "magic" MACROs, and no need to modify your data structures
   (except, perhaps, for __attribute__((packed)))
 - Uses C++ standard library as the backend for most data structures

%package devel
Summary:        Development files for libcdada
Group:          Development/Libraries/C and C++
Requires:       libcdada%{sover} = %{version}
Requires:       python3

%description devel
This package contains libraries and header files for developing
applications that use libcdada.

%prep
%autosetup
sed -i 's|#!%{_bindir}/env python3|#!%{_bindir}/python3|g' tools/cdada-gen

%build
#export CFLAGS="$RPM_OPT_FLAGS"
autoreconf -fiv
cd build
../configure --bindir=%{_bindir} --libdir=%{_libdir} --includedir=%{_includedir}
%make_build

%install
cd build
%make_install
ls %{_libdir}
ls %{_bindir}
ls %{_includedir}
rm -fv %{buildroot}/%{_libdir}/*.{a,la}

%post   -n libcdada%{sover} -p /sbin/ldconfig
%postun -n libcdada%{sover} -p /sbin/ldconfig

%files -n libcdada%{sover}
%license LICENSE
%doc AUTHORS CHANGELOG.md README.md
%doc doc/
%{_libdir}/libcdada.so.%{sover}*

%files devel
%{_bindir}/cdada-gen
%{_includedir}/cdada.h
%{_includedir}/cdada
%{_libdir}/libcdada.so

%changelog
* Fri Sep 29 2023 David Vanhoucke <dvanhoucke@redborder.com>
- Update to 0.5.1

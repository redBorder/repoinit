%global libname      librb-http
%global gh_commit    b5dc6128058c53b9be0f8244db143cd34cfb32fe
%global gh_short     %(c=%{gh_commit}; echo ${c:0:7})
%global gh_owner     bigomby
%global gh_project   %{libname}

Name:    librb-http
Summary: Rapid Development C library
Version: %{__version}
Release: %{__release}%{?dist}
%define soname %{__libver}

License: BSD-2-Clause
URL: https://gitlab.redborder.lan/core-developers/librb-http/repository/archive.tar.gz?ref=1.2.0
Source0: %{gh_project}-%{version}-%{gh_short}.tar.gz
#Source0: https://github.com/%{gh_owner}/%{gh_project}/archive/%{gh_commit}/%{gh_project}-%{version}-%{gh_short}.tar.gz

BuildRequires: gcc librd-devel libcurl-devel >= 7.48.0

Summary: Non-blocking high-level wrapper for libcurl
Group:   Development/Libraries/C and C++
%description
%{summary}

%package -n %{name}%{soname}
Summary: Non-blocking high-level wrapper for libcurl
Group:   Development/Libraries/C and C++
Requires: librd0
%description -n %{name}%{soname}
%{summary}.

%package -n %{name}-devel
Summary: Development files for %{name}
Group:   Development/Libraries/C and C++
Requires: %{name}%{soname} = %{version}-%{release}
Requires: libcurl-devel >= 7.48.0
%description -n %{name}-devel
%{summary}.

%prep
%setup -qn %{gh_project}-%{version}-%{gh_commit}

%build
./configure --prefix=/usr
make

%install
DESTDIR=%{buildroot} make install

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files -n %{name}%{soname}
%defattr(444,root,root)
/usr/lib/librbhttp.so
/usr/lib/librbhttp.so.1

%files -n %{name}-devel
%defattr(-,root,root)
%{_includedir}/librbhttp
/usr/lib/librbhttp.a

%changelog
* Tue May 10 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.2.0-1
- first spec version



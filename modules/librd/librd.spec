%global libname      librd
%global gh_commit    3a0441ca2123b3f89d879669b7ca9c047e62c8a8
%global gh_short     %(c=%{gh_commit}; echo ${c:0:7})
%global gh_owner     edenhill
%global gh_project   %{libname}

Name:    librd
Summary: Rapid Development C library
Version: 0.1.0
Release: 1%{?dist}
%define soname 0

License: BSD-2-Clause
Source0: https://github.com/%{gh_owner}/%{gh_project}/archive/%{gh_commit}/%{gh_project}-%{version}-%{gh_short}.tar.gz

BuildRequires: gcc >= 4.1 zlib-devel

Summary: Rapid Development C library
Group:   Development/Libraries/C and C++
%description
%{summary}

%package -n %{name}%{soname}
Summary: Rapid Development C library
Group:   Development/Libraries/C and C++
Requires: zlib
%description -n %{name}%{soname}
%{summary}.

%package -n %{name}-devel
Summary: Development files for %{name}
Group:   Development/Libraries/C and C++
Requires: %{name} = %{version}-%{release}
%description -n %{name}-devel
%{summary}.

%prep
#%setup -q
%setup -qn %{gh_project}-%{gh_commit}

%build
make

%install
DESTDIR=%{buildroot}/usr make install
cp LICENSE %{buildroot}/usr/share/doc/librd0/

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files -n %{name}%{soname}
%defattr(444,root,root)
/usr/lib/librd.so
/usr/lib/librd.so.0
%defattr(-,root,root)
/usr/share/doc/librd0/README.markdown
/usr/share/doc/librd0/LICENSE

%files -n %{name}-devel
%defattr(-,root,root)
%{_includedir}/librd
/usr/lib/librd.a

%changelog
* Mon May 09 2016 Juan J. Prieto <jjprieto@redborder.com> - 0.1.0-1
- first spec version



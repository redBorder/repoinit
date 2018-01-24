Name: serf
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for minio, an object storage server with Amazon S3 compatible API

Group: System Environment/Base
License: GPLv2
URL: https://github.com/minio/minio
Source0: minio

%description
Minio is an open source object storage server with Amazon S3 compatible API.

%prep

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -D -m 755 %{SOURCE0} %{buildroot}%{_bindir}

%files
%defattr(0755,root,root)
%{_bindir}/minio

%changelog
* Wed Jan 24 2018 Alberto Rodríguez <arodriguez@redborder.com> - 0.1.0-1
- first spec version

Name: minio
Version: %{__version}
Release: %{__release}%{?dist}
Summary: package for minio, an object storage server with Amazon S3 compatible API

Group: System Environment/Base
License: GPLv2
URL: https://github.com/minio/minio
Source0: minio
Source1: minio.service

%description
Minio is an open source object storage server with Amazon S3 compatible API.

%prep

%build

%pre
getent group %{name} >/dev/null || groupadd -r %{name}
getent passwd %{name} >/dev/null || \
    useradd -r -g %{name} -d /var/lib/%{name} -s /bin/bash \
    -c "User for Minio" %{name} -m
    usermod -s /sbin/nologin %{name}
exit 0

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}/etc/minio
mkdir -p %{buildroot}/var/minio/data
install -D -m 755 %{SOURCE0} %{buildroot}%{_bindir}
install -D -m 644 %{SOURCE1} %{buildroot}/usr/lib/systemd/system/minio.service

%clean
rm -rf %{buildroot}

%files
%defattr(0755,root,root)
%{_bindir}/minio
%defattr(0644,root,root)
/usr/lib/systemd/system/minio.service
%defattr(0755, %{name}, %{name})
%dir /var/minio
%dir /var/minio/data
%dir /etc/minio

%changelog
* Thu Jan 26 2023 Luis Blanco <lblanco@redborder.com> - 
- minio release fixed to 2023-01-25
* Wed Jan 24 2018 Alberto Rodríguez <arodriguez@redborder.com> - 0.1.0-2
- add unit file for systemd service management
* Wed Jan 24 2018 Alberto Rodríguez <arodriguez@redborder.com> - 0.1.0-1
- first spec version

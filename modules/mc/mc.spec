Name:           mc
Version:       %{__version}
Release:       %{__release}%{?dist}
Summary:        MinIO Client (mc) - Tool for managing object storage

License:        Apache-2.0
URL:            https://min.io
Source0:        mc
BuildArch:      x86_64

Requires:       glibc

%description
MinIO Client (mc) provides a modern alternative to UNIX commands like ls, cat, cp, mirror, diff, find, etc., 
for filesystems and object storage.

%prep
# No prep step needed since we're using a pre-built binary.

%build
# No build step needed since we're using a pre-built binary.

%install
install -Dm0755 %{SOURCE0} %{buildroot}/usr/local/bin/mc

%files
/usr/local/bin/mc

%changelog
* Tue Oct 15 2024 Miguel Negrón <manegron@redborder.com>
- Initial packaging of mc tool from MinIO as RPM

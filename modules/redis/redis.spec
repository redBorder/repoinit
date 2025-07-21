Name:           redis
Version:        8.0.3
Release:        1%{?dist}
Summary:        A persistent key-value database

License:        BSD
URL:            https://redis.io
Source0:        https://download.redis.io/releases/redis-%{version}.tar.gz

BuildRequires:  gcc make systemd-devel
Requires:       systemd shadow-utils

%description
Redis is an open-source, networked, in-memory, key-value data store.

%prep
%setup -q

%build
make %{?_smp_mflags} CFLAGS="%{optflags}" USE_SYSTEMD=yes

%install
make install PREFIX=%{buildroot}%{_prefix}
mkdir -p %{buildroot}%{_unitdir}
sed -i 's|/usr/local/bin/redis-server|%{_bindir}/redis-server|g' %{_builddir}/redis-%{version}/utils/systemd-redis_server.service
install -m 644 %{_builddir}/redis-%{version}/utils/systemd-redis_server.service %{buildroot}%{_unitdir}/redis.service
mkdir -p %{buildroot}/var/lib/redis
mkdir -p %{buildroot}%{_licensedir}/redis
install -m 644 %{_sourcedir}/LICENSE %{buildroot}%{_licensedir}/redis/

%post
if ! id redis >/dev/null 2>&1; then
  useradd -r -d /var/lib/redis -s /sbin/nologin redis
fi
chown redis:redis /var/lib/redis
chmod 750 /var/lib/redis

%files
%{_bindir}/redis-*
%{_unitdir}/redis.service
%dir /var/lib/redis
%doc README.md
%license LICENSE

%changelog
* Mon Jul 21 2025 Rafael Gómez <rgomez@redborder.com> - 8.0.3-1
- Initial package

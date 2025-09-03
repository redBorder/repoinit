%undefine __brp_mangle_shebangs
%global debug_package %{nil}

Name:    CAPEv2
Version: %{__version}
Release: %{__release}%{?dist}

Summary: Malware Configuration And Payload Extraction 
License: Apache License
URL:     https://github.com/kevoreilly/CAPEv2
Source0: CAPEv2-%{version}.tar.gz

%description
%{summary}

%prep
%setup -q -n %{name}-%{version}

%build

%install
# mkdir -p %{buildroot}/usr/lib/%{name}
# mkdir -p %{buildroot}/etc/%{name}
# install -D -m 644 %{S:1} %{buildroot}/usr/lib/systemd/system/secor.service
# install -D -m 644 output/secor-*-SNAPSHOT.jar %{buildroot}/usr/lib/%{name}
# install -D -m 644 output/secor.common.properties %{buildroot}/etc/%{name}
# install -D -m 644 output/secor.prod.properties %{buildroot}/etc/%{name}
# install -D -m 644 output/secor.prod.partition.properties %{buildroot}/etc/%{name}
mkdir -p %{buildroot}/opt/CAPEv2
cp -f -r  * %{buildroot}/opt/CAPEv2

%clean
rm -rf %{buildroot}

%pre
/usr/bin/getent group cape >/dev/null || /usr/sbin/groupadd -r cape
if ! /usr/bin/getent passwd cape >/dev/null ; then
    /usr/sbin/useradd -r -g cape -d %{_prefix}/lib/cape -s /sbin/nologin -c "cape" cape
fi

%files
%defattr(-,cape,cape)
/opt/CAPEv2
# /usr/lib/%{name}
# /etc/%{name}
# /usr/lib/systemd/system/secor.service

%changelog
* Fri Jun 24 2016 Alberto Rodriguez <arodriguez@redborder.com> 0.20-1
- first spec version

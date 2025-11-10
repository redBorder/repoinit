%undefine __brp_mangle_shebangs
%global debug_package %{nil}

Name:    cape
Version: %{__version}
Release: %{__release}%{?dist}

Summary: Malware Configuration And Payload Extraction 
License: Apache License
URL:     https://github.com/kevoreilly/CAPEv2
Source0: cape-%{version}.tar.gz
Source1: cape-rooter.service
Source2: cape-processor.service
Source3: cape.service
Source4: cape-web.service

%description
%{summary}

%prep
%setup -q -n %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/opt/CAPEv2
cp -f -r  * %{buildroot}/opt/CAPEv2
install -D -m 644 %{S:1} %{buildroot}/usr/lib/systemd/system/cape-rooter.service
install -D -m 644 %{S:2} %{buildroot}/usr/lib/systemd/system/cape-processor.service
install -D -m 644 %{S:3} %{buildroot}/usr/lib/systemd/system/cape.service
install -D -m 644 %{S:4} %{buildroot}/usr/lib/systemd/system/cape-web.service


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
/usr/lib/systemd/system/cape-rooter.service
/usr/lib/systemd/system/cape-processor.service
/usr/lib/systemd/system/cape.service
/usr/lib/systemd/system/cape-web.service

%changelog
* Fri Jun 24 2016 Alberto Rodriguez <arodriguez@redborder.com> 0.20-1
- first spec version

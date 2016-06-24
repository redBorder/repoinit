Name:    secor
Version: %{__version}
Release: %{__release}%{?dist}

Summary: Secor is a service persisting Kafka logs to Amazon S3, Google Cloud Storage and Openstack Swift
License: Apache License
URL:     https://github.com/pinterest/secor
Source0: %{name}-%{version}.tar.gz
Source1: secor.service

BuildRequires: java-devel maven git
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires: java

%description
%{summary}

%prep
%setup -q -n %{name}-%{version}

%build
mvn clean package
mkdir -p output
tar xfz target/secor-*-SNAPSHOT-bin.tar.gz -C output

%install
mkdir -p %{buildroot}/usr/lib/%{name}
mkdir -p %{buildroot}/etc/%{name}
install -D -m 644 %{S:1} %{buildroot}/usr/lib/systemd/system/secor.service
install -D -m 644 output/secor-*-SNAPSHOT.jar %{buildroot}/usr/lib/%{name}
install -D -m 644 output/secor.common.properties %{buildroot}/etc/%{name}
install -D -m 644 output/secor.prod.properties %{buildroot}/etc/%{name}
install -D -m 644 output/secor.prod.partition.properties %{buildroot}/etc/%{name}

%clean
rm -rf %{buildroot}

%files
%defattr(644,root,root)
/usr/lib/%{name}
/etc/%{name}
/usr/lib/systemd/system/secor.service

%changelog
* Fri Jun 24 2016 Alberto Rodriguez <arodriguez@redborder.com> 0.20-1
- first spec version

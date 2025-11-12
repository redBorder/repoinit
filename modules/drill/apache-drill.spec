Name: apache-drill
Version: 1.20.0
Release: 1%{?dist}
Summary: Apache Drill - Schema-free SQL Query Engine
License: Apache-2.0
URL: https://drill.apache.org
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: java-1.8.0-openjdk-devel
Requires: java-1.8.0-openjdk

%description
Apache Drill is a distributed MPP query layer that supports SQL and alternative query languages against NoSQL and Hadoop data storage systems.
This version (1.20.0) is the last available version compatible with Java 8.

%prep
%setup -q -n %{name}-%{version}

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/drill
mkdir -p %{buildroot}/etc/drill/conf

# Copy Drill files
cp -r * %{buildroot}/opt/drill/

# Create config directories and move configuration
mkdir -p %{buildroot}/etc/drill/conf
mv %{buildroot}/opt/drill/conf/* %{buildroot}/etc/drill/conf/

# Create symlinks for configuration
ln -sf /etc/drill/conf %{buildroot}/opt/drill/conf

# Install systemd service file
mkdir -p %{buildroot}/usr/lib/systemd/system

cat > %{buildroot}/usr/lib/systemd/system/drill.service << EOF
[Unit]
Description=Apache Drill Distributed SQL Engine
After=network.target

[Service]
Type=forking
User=drill
Group=drill
ExecStart=/opt/drill/bin/drillbit.sh start
ExecStop=/opt/drill/bin/drillbit.sh stop
Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0
WorkingDirectory=/opt/drill
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF


mkdir -p %{buildroot}/etc/logrotate.d
cat > %{buildroot}/etc/logrotate.d/drill << EOF
/var/log/drill/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOF

%post
if [ ! -L /opt/drill/conf ]; then
    ln -sf /etc/drill/conf /opt/drill/conf
fi

%files
%defattr(-,root,root,-)
%dir /opt/drill
/opt/drill/*
%config(noreplace) /etc/drill/conf/*
%config(noreplace) /etc/logrotate.d/drill
/usr/lib/systemd/system/drill.service

%changelog
* Tue Jan 01 2024 Juan Soto <jsoto@redborder.com> - 1.20.0-1
- Apache Drill 1.20.0 RPM package creation
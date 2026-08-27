%global python_version 3.9.25
%global grr_dir /opt/grr
%global grr_venv_path %{grr_dir}/venv
%global build_venv %{_builddir}/grr-venv
%global _build_id_links none

Name:           grr
Version:        3.4.7.1
Release:        1%{?dist}
Summary:        GRR Rapid Response server

License:        Apache-2.0
URL:            https://github.com/google/grr

Source0:        grr-3.4.7.1.tar.gz
Source1:        grr-fleetspeak.service
Source2:        grr-adminui.service
Source3:        grr-frontend.service
Source4:        grr-worker.service
Source5:        requirements.txt
Requires:       python3
Requires:       java-11-openjdk
Requires:       nodejs
Requires:       systemd

BuildRequires:  python3
BuildRequires:  python3-devel
BuildRequires:  python3-pip
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  mariadb-connector-c-devel
BuildRequires:  libffi-devel
BuildRequires:  openssl-devel
BuildRequires:  nodejs >= 18.20.8
#BuildRequires:  npm >= 10.8.2

%description
GRR Rapid Response 3.4.7.1 server packaged for Rocky Linux 9.

%prep
%setup -q -n grr-3.4.7.1


%build
# GRR is installed into an application-local Python virtual environment.

echo "========== node version =========="
node --version
echo "========== npm version =========="
# npm --version

%install

rm -rf %{buildroot}
#rm -rf %{_builddir}

mkdir -p %{buildroot}%{grr_dir}
mkdir -p %{buildroot}/etc/grr
mkdir -p %{buildroot}/usr/lib/systemd/system

# Build the Python virtual environment outside %{buildroot}
python3 -m venv %{build_venv}

cp %{_builddir}/grr-3.4.7.1/version.ini \
   %{_builddir}/grr-3.4.7.1/grr/core/version.ini

cp %{_builddir}/grr-3.4.7.1/version.ini \
   %{_builddir}/grr-3.4.7.1/grr/client_builder/version.ini

cp %{_builddir}/grr-3.4.7.1/version.ini \
   %{_builddir}/grr-3.4.7.1/grr/server/version.ini

# Rewrite shebangs
find %{build_venv}/bin -type f \
    -exec grep -lI "^#!%{build_venv}" {} \; | \
    xargs -r sed -i \
    "s|^#!%{build_venv}/bin/python.*|#!%{grr_venv_path}/bin/python3|"

# Remove BUILDROOT paths (Airflow)
grep -IlR "/builddir/build/BUILD" %{build_venv} 2>/dev/null | \
    xargs -r sed -i "s|/builddir/build/BUILD[^/]*/opt/|/opt/|g"

# Activation scripts
for script in activate activate.csh activate.fish; do
    sed -i "s|/builddir/build/BUILD/grr-venv|%{grr_venv_path}|g" \
        %{build_venv}/bin/$script
done

# Install Python dependencies into temporary venv
%{build_venv}/bin/python3 -m pip install --upgrade pip
%{build_venv}/bin/python3 -m pip install --no-cache-dir -r %{SOURCE5}


echo "========== BEFORE PROTO INSTALL =========="
%{build_venv}/bin/python3 -m pip show grr-response-proto || true
%{build_venv}/bin/python3 -m pip list | grep -i grr || true

echo "========== PROTO SOURCE =========="
pwd
ls -la %{_builddir}/grr-3.4.7.1/grr/proto/

echo "========== INSTALLING PROTO =========="
# Generate GRR protobuf Python sources
%{build_venv}/bin/python3 \
    %{_builddir}/grr-3.4.7.1/grr/proto/makefile.py --clean

# Verify generated protobuf files
echo "========== GENERATED PROTO FILES =========="
find %{_builddir}/grr-3.4.7.1/grr/proto \
    -name '*_pb2.py' -type f | sort

# Install GRR proto package
%{build_venv}/bin/python3 -m pip install \
    --no-cache-dir \
    --force-reinstall \
    %{_builddir}/grr-3.4.7.1/grr/proto/.

echo "========== AFTER PROTO INSTALL =========="
%{build_venv}/bin/python3 -m pip show grr-response-proto || true
find %{_builddir}/grr-3.4.7.1/grr/proto -maxdepth 1 -type f | sort
ls -la %{_builddir}/grr-venv/lib/python3.9/site-packages/grr_response_proto/


%{build_venv}/bin/python3 -m pip install %{_builddir}/grr-3.4.7.1/grr/core/.
%{build_venv}/bin/python3 -m pip install %{_builddir}/grr-3.4.7.1/grr/client/.
%{build_venv}/bin/python3 -m pip install %{_builddir}/grr-3.4.7.1/api_client/python/.
%{build_venv}/bin/python3 -m pip install %{_builddir}/grr-3.4.7.1/grr/client_builder/.
%{build_venv}/bin/python3 -m pip install %{_builddir}/grr-3.4.7.1/grr/server/.
%{build_venv}/bin/python3 -m pip install %{_builddir}/grr-3.4.7.1/grr/test/.

# Fix Python executable shebangs so they point to the final installation path
find %{build_venv}/bin -type f -exec sed -i \
    "1s|^#!%{build_venv}/bin/python.*$|#!/opt/grr/venv/bin/python|" {} +

find %{build_venv}/fleetspeak-server-bin/usr/bin -type f -exec sed -i \
    "1s|^#!%{build_venv}/bin/python.*$|#!/opt/grr/venv/bin/python|" {} +

# Copy completed venv into RPM buildroot
cp -a %{build_venv} %{buildroot}%{grr_dir}/venv

# Install systemd units
install -D -m 0644 %{SOURCE1} \
    %{buildroot}/usr/lib/systemd/system/grr-fleetspeak.service

install -D -m 0644 %{SOURCE2} \
    %{buildroot}/usr/lib/systemd/system/grr-adminui.service

install -D -m 0644 %{SOURCE3} \
    %{buildroot}/usr/lib/systemd/system/grr-frontend.service

install -D -m 0644 %{SOURCE4} \
    %{buildroot}/usr/lib/systemd/system/grr-worker.service

grep -R "/builddir/build" %{buildroot}%{grr_venv_path}/bin || true

head -1 %{buildroot}%{grr_venv_path}/bin/grr_server

%post
systemctl daemon-reload

%preun

%postun
systemctl daemon-reload

%files
%license LICENSE
%doc README.md

%{grr_venv_path}

/usr/lib/systemd/system/grr-fleetspeak.service
/usr/lib/systemd/system/grr-adminui.service
/usr/lib/systemd/system/grr-frontend.service
/usr/lib/systemd/system/grr-worker.service
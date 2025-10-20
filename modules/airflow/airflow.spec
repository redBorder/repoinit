%undefine __brp_mangle_shebangs
%global debug_package %{nil}

Name:    airflow
Version: %{__version}
Release: %{__release}%{?dist}

Summary: Apache Airflow - Workflow Management Platform
License: Apache-2.0
URL:     https://airflow.apache.org
Source0: apache-airflow-%{version}-source.tar.gz
Source1: airflow-webserver.service
Source2: airflow-scheduler.service
Source3: airflow-celery-worker.service

BuildArch:      noarch

%description
%{summary}

%prep
%setup -q -n apache-airflow-%{version}

%build

%install
mkdir -p %{buildroot}/opt/airflow
cp -a * %{buildroot}/opt/airflow

install -D -m 644 %{S:1} %{buildroot}/usr/lib/systemd/system/airflow-webserver.service
install -D -m 644 %{S:2} %{buildroot}/usr/lib/systemd/system/airflow-scheduler.service
install -D -m 644 %{S:2} %{buildroot}/usr/lib/systemd/system/airflow-celery-worker.service

%clean
rm -rf %{buildroot}

%pre
/usr/bin/getent group airflow >/dev/null || /usr/sbin/groupadd -r airflow
if ! /usr/bin/getent passwd airflow >/dev/null ; then
    /usr/sbin/useradd -r -g airflow -d /opt/airflow -s /sbin/nologin -c "airflow" airflow
fi

%files
%defattr(-,airflow,airflow)
/opt/airflow
/usr/lib/systemd/system/airflow-webserver.service
/usr/lib/systemd/system/airflow-scheduler.service
/usr/lib/systemd/system/airflow-celery-worker.service

%changelog
* Mon Oct 20 2025 Rafael Gómez <rgomez@redborder.com> - 3.0.6-2
- Add airflow-celery-worker.service
* Wed Sep 10 2025 Vicente Mesa <vimesa@redborder.com> - 3.0.6-1
- first spec version

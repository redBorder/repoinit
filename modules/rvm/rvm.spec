%define debug_package %{nil}
%global rvm_dir /usr/lib/rvm
%global rvm_group rvm
%global ruby_version %{__rubyversion}
%global bundler_version %{__bundlerversion}
%global rubygems_version %{__rubygemsversion}

Name: rvm
Version: %{__version}
Release: %{__release}%{?dist}
License: ASL 2.0
BuildArch: x86_64
#Source: ruby-%{ruby_version}.tar.bz2
Source0: rvm-%{version}.tar.gz
Source1: bundler-1.12.5.gem
Source2: bundle-0.0.1.gem
Source3: system-getifaddrs-0.2.1.gem
Source4: getopt-1.4.3.gem
Source5: prettyprint-0.0.1.gem
Source6: netaddr-1.5.1.gem
Source7: json-1.8.3.gem
Source8: thread_safe-0.3.5.gem
Source9: descendants_tracker-0.0.4.gem
Source10: coercible-1.0.0.gem
Source11: symmetric-encryption-3.8.3.gem
Source12: arp_scan-0.1.0.gem
Source13: knife-acl-0.0.12.gem
Source14: chef-12.0.3.gem
Source15: rake-10.1.0.gem
Source16: mrdialog-1.0.3.gem
Source17: net-ip-0.0.8.gem
Source18: backports-3.6.8.gem
Source19: specific_install-0.3.2.gem
Source20: rails-4.0.12.gem
Source21: railties-4.0.12.gem
Source22: newrelic_rpm-3.15.0.314.gem
Source23: jquery-rails-3.1.4.gem
Source24: jquery-ui-rails-5.0.5.gem
Source25: devise-3.5.10.gem
Source26: simple_form-3.1.1.gem
Source27: will_paginate-3.0.7.gem
Source28: awesome_nested_set-3.0.3.gem
Source29: daemons-1.1.9.gem
Source30: delayed_job_active_record-4.0.3.gem
Source31: net-scp-1.1.2.gem
Source32: turbolinks-1.3.1.gem
Source33: jquery-turbolinks-0.2.1.gem
Source34: lograge-0.3.6.gem
Source35: jbuilder-1.0.2.gem
Source36: druid_config-0.5.0.gem
Source37: oauth2-1.1.0.gem
Source38: zendesk_api-1.12.1.gem
Source39: unicorn-5.0.1.gem
Source40: therubyracer-0.11.4.gem
Source41: geoip-1.3.5.gem
Source42: zeroclipboard-rails-0.1.1.gem
Source43: countries-0.9.3.gem
Source44: whois-3.4.5.gem
Source45: net-dns-0.8.0.gem
Source46: aws-sdk-1.61.0.gem
Source47: aws-s3-0.6.3.gem
Source48: paperclip-3.5.4.gem
Source49: posix-spawn-0.3.11.gem
Source50: dalli-2.7.6.gem
Source51: dimensions-1.3.0.gem
Source52: jscolor-rails-1.4.2.1.gem
Source53: timecop-0.7.4.gem
Source54: pg-0.17.1.gem
Source55: gcm-0.0.9.gem
Source56: ditto_code-0.3.5.gem
Source57: wicked_pdf-0.11.0.gem
Source58: rmagick-2.13.4.gem
Source59: snmp-1.2.0.gem
Source60: snmp4em-1.1.2.gem
Source61: upsert-2.1.2.gem
Source62: toastr-rails-1.0.3.gem

BuildRequires: libyaml-devel libffi-devel autoconf automake libtool bison postgresql-devel ImageMagick-devel git
BuildRequires: gcc-c++ patch readline readline-devel zlib-devel openssl-devel procps-ng sqlite-devel
#BuildRequires: patch readline procps-ng
Requires: sed grep tar gzip bzip2 make file dialog
Summary: Rvm and ruby

%description
Rvm with ruby, gem, and bundler, packaged as an rpm. System level install.
Versions: ruby-%{ruby_version}, bundler-%{bundler_version} and
rubygems-%{rubygems_version}

%prep
%setup -q -n rvm-%{version}

%build
rvm_path="%{rvm_dir}" \
  rvm_man_path="%{_mandir}" \
  ./install --auto-dotfiles &>/dev/null

echo "" > %{rvm_dir}/gemsets/default.gems
echo "" > %{rvm_dir}/gemsets/global.gems

echo "
umask u=rwx,g=rwx,o=rx
rvm_path="%{rvm_dir}"
rvm_archives_path=%{rvm_dir}/archives
rvm_autolibs_flag=read-fail
" > /etc/rvmrc

cp -rf $RPM_SOURCE_DIR/* %{rvm_dir}/archives/
chgrp -R rvm %{rvm_dir}
chmod -R g+wxr %{rvm_dir}

%{rvm_dir}/bin/rvm install %{ruby_version}

echo "
current=ruby-%{ruby_version}
default=ruby-%{ruby_version}
" > %{rvm_dir}/config/alias

# install bundle gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundler-*.gem
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/bundle-*.gem

# install global basic gems
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/prettyprint-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/getopt-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/netaddr-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/system-getifaddrs-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/json-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/thread_safe-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/descendants_tracker-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/coercible-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/symmetric-encryption-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/arp_scan-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/knife-acl-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/chef-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/rake-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/mrdialog-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/net-ip-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/backports-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@global do gem install %{rvm_dir}/archives/specific_install-*.gem --no-ri

# Create web gemset
%{rvm_dir}/bin/rvm all do rvm gemset create web

# install webui gems
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/rails-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/railties-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/newrelic_rpm-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/jquery-rails-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/jquery-ui-rails-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/devise-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/simple_form-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/will_paginate-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/awesome_nested_set-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/daemons-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/delayed_job_active_record-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/net-scp-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/turbolinks-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/jquery-turbolinks-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/lograge-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/jbuilder-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/druid_config-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/oauth2-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/zendesk_api-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/unicorn-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/therubyracer-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/geoip-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/zeroclipboard-rails-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/countries-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/whois-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/net-dns-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/aws-sdk-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/aws-s3-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/paperclip-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/posix-spawn-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/dalli-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/dimensions-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/jscolor-rails-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/timecop-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/pg-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/gcm-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/ditto_code-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/wicked_pdf-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/rmagick-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/snmp-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/snmp4em-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/upsert-*.gem --no-ri
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem install %{rvm_dir}/archives/toastr-rails-*.gem --no-ri

# gems from github
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem specific_install https://github.com/redBorder/devise_ldap_authenticatable.git
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem specific_install https://github.com/redBorder/ruby-druid.git rb-0.1.9
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem specific_install https://github.com/redBorder/audited.git
%{rvm_dir}/bin/rvm %{ruby_version}@web do gem specific_install https://github.com/redBorder/wash_out.git

# Remove downloaded gems and files after compilation
rm -rf %{rvm_dir}/src/*
rm -rf %{rvm_dir}/log/*
rm -rf %{rvm_dir}/archives/*

%install
rm -rf $RPM_BUILD_ROOT/*
mkdir -p $RPM_BUILD_ROOT/%{rvm_dir}
mkdir -p $RPM_BUILD_ROOT/etc
mkdir -p $RPM_BUILD_ROOT/etc/profile.d

cp -rf %{rvm_dir}/* $RPM_BUILD_ROOT/%{rvm_dir}/
cp /etc/profile.d/rvm.sh $RPM_BUILD_ROOT/etc/profile.d/rvm.sh
cp /etc/rvmrc $RPM_BUILD_ROOT/etc/rvmrc

chgrp -R rvm $RPM_BUILD_ROOT/%{rvm_dir}
chmod -R g+wxr $RPM_BUILD_ROOT/%{rvm_dir}

ruby -p -i -e 'gsub(%r{#!.*/this/will/be/overwritten/or/wrapped/anyways/do/not/worry/ruby}, "#!/usr/bin/ruby")' \
  %{rvm_dir}/rubies/ruby-%{__rubyversion}/lib/ruby/gems/2.2.0/bin/*

%clean

%pre
getent group rvm >/dev/null || groupadd -r rvm

%post
/bin/bash --login -c "rvm use %{ruby_version} --default" || :

%files
%{rvm_dir}
/etc/rvmrc
/etc/profile.d/rvm.sh

%changelog
* Thu Nov 17 2016 Carlos J. Mateos <cjmateos@redborder.com> - 1.27.0-2
- Updated to latest version
* Fri Jun 17 2016 Juan J. Prieto <jjprieto@redborder.com> - 1.27.0-1
- Updated to latest version

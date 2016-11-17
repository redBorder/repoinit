#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.27.0"}
RELEASE=${RELEASE:="2"}
PACKNAME=${PACKNAME:="rvm"}
BUNDLER_VERSION=${BUNDLER_VERSION:="1.12.5"}
RUBYGEMS_VERSION=${RUBYGEMS_VERSION:="2.4.8"}
#RUBY_VERSION=${RUBY_VERSION:="2.2.4"}
RUBY_VERSION=${RUBY_VERSION:="2.2.2"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

#list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.src.rpm
#                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.noarch.rpm
#                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.noarch.rpm"
#
#if [ "x$1" != "xforce" ]; then
#        f_check "${list_of_packages}"
#        if [ $? -eq 0 ]; then
#                # the rpms exist and we don't need to create again
#                exit 0
#        fi
#fi

# First we need to download source
mkdir SOURCES
wget --no-check-certificate https://github.com/rvm/${PACKNAME}/archive/${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz
#wget --no-check-certificate https://ftp.ruby-lang.org/pub/ruby/2.2/ruby-${RUBY_VERSION}.tar.bz2 -O SOURCES/ruby-${RUBY_VERSION}.tar.bz2
#wget --no-check-certificate https://rubygems.org/rubygems/rubygems-${RUBYGEMS_VERSION}.tgz -O SOURCES/rubygems-${RUBYGEMS_VERSION}.tar.gz
wget --no-check-certificate https://rubygems.org/downloads/bundler-1.12.5.gem -O SOURCES/bundler-1.12.5.gem
wget --no-check-certificate https://rubygems.org/downloads/bundle-0.0.1.gem -O SOURCES/bundle-0.0.1.gem
wget --no-check-certificate https://rubygems.org/downloads/system-getifaddrs-0.2.1.gem -O SOURCES/system-getifaddrs-0.2.1.gem
wget --no-check-certificate https://rubygems.org/downloads/prettyprint-0.0.1.gem -O SOURCES/prettyprint-0.0.1.gem
wget --no-check-certificate https://rubygems.org/downloads/getopt-1.4.3.gem -O SOURCES/getopt-1.4.3.gem
wget --no-check-certificate https://rubygems.org/downloads/netaddr-1.5.1.gem -O SOURCES/netaddr-1.5.1.gem
wget --no-check-certificate https://rubygems.org/downloads/json-1.8.3.gem -O SOURCES/json-1.8.3.gem
wget --no-check-certificate https://rubygems.org/downloads/arp_scan-0.1.0.gem -O SOURCES/arp_scan-0.1.0.gem
wget --no-check-certificate https://rubygems.org/downloads/knife-acl-0.0.12.gem -O SOURCES/knife-acl-0.0.12.gem
wget --no-check-certificate https://rubygems.org/downloads/chef-12.0.3.gem -O SOURCES/chef-12.0.3.gem
wget --no-check-certificate https://rubygems.org/downloads/rake-10.1.0.gem -O SOURCES/rake-10.1.0.gem
wget --no-check-certificate https://rubygems.org/downloads/mrdialog-1.0.3.gem -O SOURCES/mrdialog-1.0.3.gem
wget --no-check-certificate https://rubygems.org/downloads/net-ip-0.0.8.gem -O SOURCES/net-ip-0.0.8.gem
wget --no-check-certificate https://rubygems.org/downloads/backports-3.6.8.gem -O SOURCES/backports-3.6.8.gem
wget --no-check-certificate https://rubygems.org/downloads/specific_install-0.3.2.gem -O SOURCES/specific_install-0.3.2.gem

# Symmetric Encryption dependencies
wget --no-check-certificate https://rubygems.org/downloads/thread_safe-0.3.5.gem -O SOURCES/thread_safe-0.3.5.gem
wget --no-check-certificate https://rubygems.org/downloads/descendants_tracker-0.0.4.gem -O SOURCES/descendants_tracker-0.0.4.gem
wget --no-check-certificate https://rubygems.org/downloads/coercible-1.0.0.gem -O SOURCES/coercible-1.0.0.gem
wget --no-check-certificate https://rubygems.org/downloads/symmetric-encryption-3.8.3.gem -O SOURCES/symmetric-encryption-3.8.3.gem

# Webui GEMs
wget --no-check-certificate https://rubygems.org/downloads/rails-4.0.12.gem -O SOURCES/rails-4.0.12.gem
wget --no-check-certificate https://rubygems.org/downloads/railties-4.0.12.gem -O SOURCES/railties-4.0.12.gem
wget --no-check-certificate https://rubygems.org/downloads/newrelic_rpm-3.15.0.314.gem -O SOURCES/newrelic_rpm-3.15.0.314.gem
wget --no-check-certificate https://rubygems.org/downloads/jquery-rails-3.1.4.gem -O SOURCES/jquery-rails-3.1.4.gem
wget --no-check-certificate https://rubygems.org/downloads/jquery-ui-rails-5.0.5.gem -O SOURCES/jquery-ui-rails-5.0.5.gem
wget --no-check-certificate https://rubygems.org/downloads/devise-3.5.10.gem -O SOURCES/devise-3.5.10.gem
wget --no-check-certificate https://rubygems.org/downloads/simple_form-3.1.1.gem -O SOURCES/simple_form-3.1.1.gem
wget --no-check-certificate https://rubygems.org/downloads/will_paginate-3.0.7.gem -O SOURCES/will_paginate-3.0.7.gem
wget --no-check-certificate https://rubygems.org/downloads/awesome_nested_set-3.0.3.gem -O SOURCES/awesome_nested_set-3.0.3.gem
wget --no-check-certificate https://rubygems.org/downloads/daemons-1.1.9.gem -O SOURCES/daemons-1.1.9.gem
wget --no-check-certificate https://rubygems.org/downloads/delayed_job_active_record-4.0.3.gem -O SOURCES/delayed_job_active_record-4.0.3.gem
wget --no-check-certificate https://rubygems.org/downloads/net-scp-1.1.2.gem -O SOURCES/net-scp-1.1.2.gem
wget --no-check-certificate https://rubygems.org/downloads/turbolinks-1.3.1.gem -O SOURCES/turbolinks-1.3.1.gem
wget --no-check-certificate https://rubygems.org/downloads/jquery-turbolinks-0.2.1.gem -O SOURCES/jquery-turbolinks-0.2.1.gem
wget --no-check-certificate https://rubygems.org/downloads/lograge-0.3.6.gem -O SOURCES/lograge-0.3.6.gem
wget --no-check-certificate https://rubygems.org/downloads/jbuilder-1.0.2.gem -O SOURCES/jbuilder-1.0.2.gem
wget --no-check-certificate https://rubygems.org/downloads/druid_config-0.5.0.gem -O SOURCES/druid_config-0.5.0.gem
wget --no-check-certificate https://rubygems.org/downloads/oauth2-1.1.0.gem -O SOURCES/oauth2-1.1.0.gem
wget --no-check-certificate https://rubygems.org/downloads/zendesk_api-1.12.1.gem -O SOURCES/zendesk_api-1.12.1.gem
wget --no-check-certificate https://rubygems.org/downloads/unicorn-5.0.1.gem -O SOURCES/unicorn-5.0.1.gem
wget --no-check-certificate https://rubygems.org/downloads/therubyracer-0.11.4.gem -O SOURCES/therubyracer-0.11.4.gem
wget --no-check-certificate https://rubygems.org/downloads/geoip-1.3.5.gem -O SOURCES/geoip-1.3.5.gem
wget --no-check-certificate https://rubygems.org/downloads/zeroclipboard-rails-0.1.1.gem -O SOURCES/zeroclipboard-rails-0.1.1.gem
wget --no-check-certificate https://rubygems.org/downloads/countries-0.9.3.gem -O SOURCES/countries-0.9.3.gem
wget --no-check-certificate https://rubygems.org/downloads/whois-3.4.5.gem -O SOURCES/whois-3.4.5.gem
wget --no-check-certificate https://rubygems.org/downloads/net-dns-0.8.0.gem -O SOURCES/net-dns-0.8.0.gem
wget --no-check-certificate https://rubygems.org/downloads/aws-sdk-1.61.0.gem -O SOURCES/aws-sdk-1.61.0.gem
wget --no-check-certificate https://rubygems.org/downloads/aws-s3-0.6.3.gem -O SOURCES/aws-s3-0.6.3.gem
wget --no-check-certificate https://rubygems.org/downloads/paperclip-3.5.4.gem -O SOURCES/paperclip-3.5.4.gem
wget --no-check-certificate https://rubygems.org/downloads/posix-spawn-0.3.11.gem -O SOURCES/posix-spawn-0.3.11.gem
wget --no-check-certificate https://rubygems.org/downloads/dalli-2.7.6.gem -O SOURCES/dalli-2.7.6.gem
wget --no-check-certificate https://rubygems.org/downloads/dimensions-1.3.0.gem -O SOURCES/dimensions-1.3.0.gem
wget --no-check-certificate https://rubygems.org/downloads/jscolor-rails-1.4.2.1.gem -O SOURCES/jscolor-rails-1.4.2.1.gem
wget --no-check-certificate https://rubygems.org/downloads/timecop-0.7.4.gem -O SOURCES/timecop-0.7.4.gem
wget --no-check-certificate https://rubygems.org/downloads/pg-0.17.1.gem -O SOURCES/pg-0.17.1.gem
# Gem to push mobile notifications
wget --no-check-certificate https://rubygems.org/downloads/gcm-0.0.9.gem -O SOURCES/gcm-0.0.9.gem
wget --no-check-certificate https://rubygems.org/downloads/ditto_code-0.3.5.gem -O SOURCES/ditto_code-0.3.5.gem
wget --no-check-certificate https://rubygems.org/downloads/wicked_pdf-0.11.0.gem -O SOURCES/wicked_pdf-0.11.0.gem
wget --no-check-certificate https://rubygems.org/downloads/rmagick-2.13.4.gem -O SOURCES/rmagick-2.13.4.gem
wget --no-check-certificate https://rubygems.org/downloads/snmp-1.2.0.gem -O SOURCES/snmp-1.2.0.gem
wget --no-check-certificate https://rubygems.org/downloads/snmp4em-1.1.2.gem -O SOURCES/snmp4em-1.1.2.gem
wget --no-check-certificate https://rubygems.org/downloads/upsert-2.1.2.gem -O SOURCES/upsert-2.1.2.gem
wget --no-check-certificate https://rubygems.org/downloads/toastr-rails-1.0.3.gem -O SOURCES/toastr-rails-1.0.3.gem

# Patch and rebuild chef gem due a bug in data_bag_item script
pushd SOURCES &>/dev/null
gem unpack ./chef-12.0.3.gem --target=tmp
pushd tmp &>/dev/null
patch -p1 <../../patches/data_bag_item.patch
popd &>/dev/null
gem spec ./chef-12.0.3.gem --ruby > tmp/chef-12.0.3/chef-12.0.3.gemspec
pushd tmp/chef-12.0.3 &>/dev/null
gem build chef-12.0.3.gemspec
popd &>/dev/null
rm -f chef-12.0.3.gem
mv tmp/chef-12.0.3/chef-12.0.3.gem .
popd &>/dev/null

cp rvmrc rvm.sh SOURCES

# Now it is time to create the source rpm
/usr/bin/mock \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--define "__rubyversion ${RUBY_VERSION}" \
	--define "__rubygemsversion ${RUBYGEMS_VERSION}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--define "__rubyversion ${RUBY_VERSION}" \
	--define "__rubygemsversion ${RUBYGEMS_VERSION}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?

# cleaning
rm -rf SOURCES

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
#f_rsync_iso pkgs/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
#f_rsync_repo pkgs/${PACKNAME}*.rpm
#rm -rf pkgs
#
# Update sdk7 repo
#f_rupdaterepo

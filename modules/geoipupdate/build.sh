#!/bin/bash

# Packets generated:
#   GeoIP-1.6.9-2.el7.rb.x86_64.rpm
#   GeoIP-GeoLite-data-2016.10-1.el7.rb.noarch.rpm
#   GeoIP-GeoLite-data-extra-2016.10-1.el7.rb.noarch.rpm
#   geoipupdate-2.2.2-2.el7.rb.x86_64.rpm
#   geoipupdate-cron-2.2.2-2.el7.rb.noarch.rpm

source build_common.sh

VERSION=${VERSION:="2.2.2"}
RELEASE=${RELEASE:="2"}
PACKNAME=${PACKNAME:="geoipupdate"}

# First we need to download source
mkdir SOURCES
wget ftp://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/source/tree/Packages/g/geoipupdate-2.2.2-2.fc24.src.rpm -O SOURCES/geoipupdate-2.2.2-2.fc24.src.rpm
wget ftp://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/source/tree/Packages/g/GeoIP-1.6.9-2.fc24.src.rpm -O SOURCES/GeoIP-1.6.9-2.fc24.src.rpm
wget ftp://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/source/tree/Packages/g/GeoIP-GeoLite-data-2016.10-1.fc26.src.rpm -O SOURCES/GeoIP-GeoLite-data-2016.10-1.fc26.src.rpm

# with it, we can create rest of packages
/usr/bin/mock -r default \
	--resultdir=../../pkgs --rebuild SOURCES/geoipupdate-2.2.2-2.fc24.src.rpm
/usr/bin/mock -r default \
	--resultdir=../../pkgs --rebuild SOURCES/GeoIP-1.6.9-2.fc24.src.rpm
/usr/bin/mock -r default \
	--resultdir=../../pkgs --rebuild SOURCES/GeoIP-GeoLite-data-2016.10-1.fc26.src.rpm

ret=$?

# cleaning
rm -rf SOURCES

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi


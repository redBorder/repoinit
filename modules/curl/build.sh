#!/bin/bash

source build_common.sh

VERSION=${VERSION:="7.48.0"}
PACKNAME=${PACKNAME:="curl"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}

# First we need to download source
mkdir SOURCES
wget http://nervion.us.es/city-fan/yum-repo/rhel7/source/curl-${VERSION}-1.0.cf.rhel7.src.rpm -O SOURCES/curl-${VERSION}-1.0.cf.rhel7.src.rpm
pushd SOURCES &>/dev/null
rpm2cpio curl-${VERSION}-1.0.cf.rhel7.src.rpm | cpio -idmv
popd &>/dev/null

# Now it is time to create the source rpm
/usr/bin/mock -r sdk7 --resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk7 --resultdir=pkgs --rebuild pkgs/curl*.src.rpm

# cleaning
rm -rf SOURCES

# sync to cache and repo
rsync -a pkgs/curl-${VERSION}*.el7.centos.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/libcurl-${VERSION}*.el7.centos.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/*.rpm ${REPODIR}
rm -rf pkgs

# Update sdk7 repo
f_updaterepo ${REPODIR}


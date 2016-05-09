#!/bin/bash

VERSION=${VERSION:="7.48.0"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}

# First we need to download source
mkdir pkgs
wget http://nervion.us.es/city-fan/yum-repo/rhel7/source/curl-${VERSION}-1.0.cf.rhel7.src.rpm -O pkgs/curl-${VERSION}-1.0.cf.rhel7.src.rpm

# with it, we can create rest of packages
/usr/bin/mock -r default --resultdir=pkgs --rebuild pkgs/curl*.src.rpm

# sync to cache and repo
rsync -a pkgs/curl-${VERSION}-1.0.cf.rhel7.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/libcurl-${VERSION}-1.0.cf.rhel7.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/*.rpm ${REPODIR}
rm -rf pkgs


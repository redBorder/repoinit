#!/bin/bash

VERSION=${VERSION:="1.1.2"}
PACKNAME=${PACKNAME:="librb-http"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}

# First we need to download source
mkdir SOURCES
wget --no-check-certificate https://gitlab.redborder.lan/core-developers/${PACKNAME}/repository/archive.tar.gz?ref=${VERSION} --header='PRIVATE-TOKEN:oDRezN5gFLgBB6nWsMZU' -O SOURCES/${PACKNAME}-${VERSION}.tar.gz

## Now it is time to create the source rpm
#/usr/bin/mock -r default --define "__version ${VERSION}" --define "__release 1" --resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES
#
## with it, we can create rest of packages
#/usr/bin/mock -r default --define "__version ${VERSION}" --define "__release 1" --resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm
#
## cleaning
#rm -rf SOURCES
#
## sync to cache and repo
#rsync -a pkgs/${PACKNAME}*.el7.centos.x86_64.rpm ${CACHEDIR}
#rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
#rm -rf pkgs


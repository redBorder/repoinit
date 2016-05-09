#!/bin/bash

COMMIT=${COMMIT:="3a0441ca2123b3f89d879669b7ca9c047e62c8a8"}
VERSION=${VERSION:="0.1.0"}
PACKNAME=${PACKNAME:="librd"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}
VSHORT=$(c=${COMMIT}; echo ${c:0:7})

# First we need to download source
mkdir SOURCES
wget https://github.com/edenhill/${PACKNAME}/archive/${COMMIT}/${PACKNAME}-${VERSION}-${VSHORT}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}-${VSHORT}.tar.gz

# Now it is time to create the source rpm
/usr/bin/mock -r default --resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r default --resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

# cleaning
rm -rf SOURCES

# sync to cache and repo
rsync -a pkgs/${PACKNAME}*.el7.centos.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
rm -rf pkgs


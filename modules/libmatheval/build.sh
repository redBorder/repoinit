#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.1.11"}
PACKNAME=${PACKNAME:="libmatheval"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}
VSHORT=$(c=${COMMIT}; echo ${c:0:7})

# First we need to download source
mkdir SOURCES
wget http://ftp.gnu.org/gnu/${PACKNAME}/${PACKNAME}-${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz

# Now it is time to create the source rpm
/usr/bin/mock -r sdk7 --resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk7 --resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

# cleaning
rm -rf SOURCES

# sync to cache and repo
rsync -a pkgs/${PACKNAME}*.el7.centos.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
rm -rf pkgs

# Update sdk7 repo
f_updaterepo ${REPODIR}


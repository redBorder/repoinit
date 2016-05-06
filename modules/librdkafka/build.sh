#!/bin/bash

VERSION=${VERSION:="0.8.4"}
PACKNAME=${PACKNAME:="librdkafka"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}

# First we need to download source
mkdir SOURCES
wget https://github.com/edenhill/librdkafka/archive/${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz

# Now it is time to create the source rpm
/usr/bin/mock -r default --define "__version ${VERSION}" --define "__release 1" --resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r default --define "__version ${VERSION}" --define "__release 1" --resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

# cleaning
rm -rf SOURCES

# sync to cache and repo
rsync -a pkgs/${PACKNAME}*.el7.centos.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
rm -rf pkgs


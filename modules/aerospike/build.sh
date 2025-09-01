#!/bin/bash

source build_common.sh

VERSION=${VERSION:="8.1.0.0"}
TOOLSVERSION=${TOOLSVERSION:="12.0.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="aerospike"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
URL="https://download.aerospike.com/artifacts/aerospike-server-community/${VERSION}/aerospike-server-community_${VERSION}_tools-${TOOLSVERSION}_el9_x86_64.tgz"
mkdir SOURCES
wget ${URL} -O SOURCES/${PACKNAME}-${VERSION}.tar.gz
mkdir pkgs
tar -xzf SOURCES/${PACKNAME}-${VERSION}.tar.gz -C pkgs --strip-components=1

# sync to cache and repo
f_rsync_repo pkgs/aerospike-server-community-${VERSION}-${RELEASE}.el9.x86_64.rpm
f_rsync_iso pkgs/aerospike-server-community-${VERSION}-${RELEASE}.el9.x86_64.rpm

# cleaning
rm -rf SOURCES
rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}


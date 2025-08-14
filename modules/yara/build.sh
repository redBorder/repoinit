#!/bin/bash

source build_common.sh

VERSION=${VERSION:="4.5.2"}
TOOLSVERSION=${TOOLSVERSION:="12.0.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="yara"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm"
                
if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

mkdir pkgs
mkdir SOURCES
wget http://rpmfind.net/linux/centos-stream/9-stream/AppStream/x86_64/os/Packages/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
wget http://mirror.stream.centos.org/9-stream/AppStream/source/tree/Packages/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm -O SOURCES/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm

# sync to cache and repo
f_rsync_repo pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
f_rsync_iso pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm

# cleaning
rm -rf SOURCES
rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}
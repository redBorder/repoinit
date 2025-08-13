#!/bin/bash

source build_common.sh

VERSION=${VERSION:="4.5.4"}
TOOLSVERSION=${TOOLSVERSION:="12.0.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="yara"}
# CACHEDIR=${CACHEDIR:="/isos/ng/devel/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/devel/ptorres/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/devel/ptorres/rhel/9/SRPMS"}
# VOLVER A añadir el cachedir donde va
# ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm"

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
                

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
URL="https://github.com/VirusTotal/yara/archive/refs/tags/v${VERSION}.tar.gz"
mkdir SOURCES
wget ${URL} -O SOURCES/${PACKNAME}-${VERSION}.tar.gz
mkdir pkgs
tar -xzf SOURCES/${PACKNAME}-${VERSION}.tar.gz -C pkgs --strip-components=1

# # sync to cache and repo
# f_rsync_repo pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
# f_rsync_iso pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm

# # cleaning
# rm -rf SOURCES
# rm -rf pkgs

# # Update sdk9 repo
# f_rupdaterepo ${REPODIR}
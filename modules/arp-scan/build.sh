#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.10.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="arp-scan"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
                 ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
                ${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm"

if [ "x$1" != "xforce" ]; then
       f_check "${list_of_packages}"
       if [ $? -eq 0 ]; then
               # the rpms exist and we don't need to create again
               exit 0
       fi
fi

# First we need to download source
rm -rf pkgs
rm -rf SOURCES

mkdir pkgs
mkdir SOURCES

wget https://rpmfind.net/linux/epel/9/Everything/x86_64/Packages/a/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm ... exiting"
        exit 1
fi

wget https://yum.oracle.com/repo/OracleLinux/OL9/developer/EPEL/aarch64/getPackageSource/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm -O SOURCES/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.rpm
f_rsync_repo_SRPMS SOURCES/*.rpm
f_rsync_iso pkgs/*.rpm

rm -rf pkgs
rm -rf SOURCES

# Update sdk9 repo
f_rupdaterepo $REPODIR
f_rupdaterepo $REPODIR_SRPMS



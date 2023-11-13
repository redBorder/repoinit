#!/bin/bash

source build_common.sh

VERSION=${VERSION:="10.11.5"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="network-scripts"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm
                ${REPODIR_SRPMS}/libteam-1.31-16.el9_1.src.rpm
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
                ${REPODIR}/network-scripts-teamd-1.31-16.el9_1.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm"

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

wget https://dl.rockylinux.org/pub/rocky/9/devel/source/tree/Packages/i/initscripts-${VERSION}-${RELEASE}.el9.src.rpm -O SOURCES/initscripts-${VERSION}-${RELEASE}.el9.src.rpm 

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting initscripts-${VERSION}-${RELEASE}.el9.src.rpm ... exiting"
        exit 1
fi

wget https://dl.rockylinux.org/pub/rocky/9/devel/source/tree/Packages/l/libteam-1.31-16.el9_1.src.rpm -O SOURCES/libteam-1.31-16.el9_1.src.rpm  

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting libteam-1.31-16.el9_1.src.rpm  ... exiting"
        exit 1
fi

wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/n/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm ... exiting"
        exit 1
fi

wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/n/network-scripts-teamd-1.31-16.el9_1.x86_64.rpm -O pkgs/network-scripts-teamd-1.31-16.el9_1.x86_64.rpm 

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting network-scripts-teamd-1.31-16.el9_1.x86_64.rpm ... exiting"
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



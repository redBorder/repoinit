#!/bin/bash

source build_common.sh

VERSION=${VERSION:="2.1.0"}
RELEASE=${RELEASE:="5"}
PACKNAME=${PACKNAME:="yajl"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-devel-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-devel-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
rm -rf pkgs
mkdir pkgs
#wget https://dl.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/y/yajl-${VERSION}-${RELEASE}.fc24.src.rpm -O pkgs/yajl-${VERSION}-${RELEASE}.fc24.src.rpm
wget ftp://ftp.pbone.net/mirror/archive.fedoraproject.org/fedora/linux/releases/24/Server/source/tree/Packages/y/yajl-${VERSION}-${RELEASE}.fc24.src.rpm -O pkgs/yajl-${VERSION}-${RELEASE}.fc24.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting yajl-${VERSION}-${RELEASE}.fc24.src.rpm... exiting"
        exit 1
fi

# with it, we can create rest of packages
/usr/bin/mock -r sdk7 \
	--resultdir=pkgs --rebuild pkgs/yajl-${VERSION}-${RELEASE}.fc24.src.rpm

ret=$?

rm -f pkgs/yajl-${VERSION}-${RELEASE}.fc24.src.rpm

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm
f_rsync_repo_SRPMS pkgs/*.src.rpm
f_rsync_iso pkgs/*.x86_64.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}
f_rupdaterepo $REPODIR_SRPMS

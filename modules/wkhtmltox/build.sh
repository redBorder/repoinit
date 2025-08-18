#!/bin/bash

source build_common.sh

VERSION=${VERSION:="0.12.6.1"}
RELEASE=${RELEASE:="3"}
PACKNAME=${PACKNAME:="wkhtmltox"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.almalinux9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.almalinux9.x86_64.rpm
                 "
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
# wkhtmltox rpms

wget https://github.com/wkhtmltopdf/packaging/releases/download/${VERSION}-${RELEASE}/${PACKNAME}-${VERSION}-${RELEASE}.almalinux9.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.almalinux9.x86_64.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.almalinux9.x86_64.rpm... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm
f_rsync_iso pkgs/*.x86_64.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}

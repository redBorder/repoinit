#!/bin/bash

source build_common.sh

VERSION=${VERSION:="12.11.18"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="chef"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm 
               ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm"

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

wget https://packages.chef.io/stable/el/7/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.rpm
f_rsync_iso pkgs/*.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo $REPODIR


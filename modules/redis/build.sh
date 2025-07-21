#!/bin/bash

source build_common.sh

RELEASE=${RELEASE:="1"}
VERSION=${VERSION:="6.2.18"}
PACKNAME=${PACKNAME:="redis"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9_6.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
  f_check "${list_of_packages}"
  if [ $? -eq 0 ]; then
    # the rpms exist and we don't need to create again
    exit 0
  fi
fi

# Download Redis source
mkdir pkgs
wget https://download.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/Packages/r/${PACKNAME}-${VERSION}-${RELEASE}.el9_6.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9_6.x86_64.rpm

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}

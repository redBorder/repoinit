#!/bin/bash

source build_common.sh

VERSION=${VERSION:="12.11.18"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="chef"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

#list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm 
#                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm"
#
#if [ "x$1" != "xforce" ]; then
#        f_check "${list_of_packages}"
#        if [ $? -eq 0 ]; then
#                # the rpms exist and we don't need to create again
#                exit 0
#        fi
#fi

# First we need to download source
mkdir pkgs
wget https://packages.chef.io/stable/el/7/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm

# sync to cache and repo
#f_rsync_repo pkgs/${PACKNAME}*.rpm
#f_rsync_iso pkgs/${PACKNAME}*.rpm
#rm -rf pkgs

# Update sdk7 repo
#f_rupdaterepo ${REPODIR}


#!/bin/bash

source build_common.sh

MAJOR_VERSION=${MAJOR_VERSION:="2.1"}
VERSION=${VERSION:="7.15.2"}
PACKNAME=${PACKNAME:="logstash"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-${VERSION}-x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir pkgs
wget https://artifacts.elastic.co/downloads/logstash/${PACKNAME}-${VERSION}-x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-x86_64.rpm

# sync to cache and repo
f_rsync_repo pkgs/${PACKNAME}*.rpm
f_rsync_iso pkgs/${PACKNAME}*.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}

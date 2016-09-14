#!/bin/bash

source build_common.sh

MAJOR_VERSION=${MAJOR_VERSION:="2.1"}
VERSION=${VERSION:="2.1.1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="riak-cs"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir pkgs
wget http://s3.amazonaws.com/downloads.basho.com/${PACKNAME}/${MAJOR_VERSION}/${VERSION}/rhel/7/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
wget http://s3.amazonaws.com/downloads.basho.com/${PACKNAME}/${MAJOR_VERSION}/${VERSION}/rhel/7/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm

# sync to cache and repo
f_rsync_repo pkgs/${PACKNAME}*.rpm
f_rsync_iso pkgs/${PACKNAME}*.rpm
rm -rf pkgs

# Update sdk7 repo
f_rupdaterepo ${REPODIR}

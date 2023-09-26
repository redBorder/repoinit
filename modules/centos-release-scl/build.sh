#!/bin/bash

source build_common.sh

VERSION=${VERSION:="12.7.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="chef-server-core"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-rh-${VERSION}-${RELEASE}.el7.centos.noarch.rpm 
                ${CACHEDIR}/${PACKNAME}-rh-${VERSION}-${RELEASE}.el7.centos.noarch.rpm
                ${REPODIR}/${PACKNAME}-rh-${VERSION}-${RELEASE}.el7.centos.src.rpm
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.noarch.rpm 
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.noarch.rpm
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir pkgs
wget https://packages.chef.io/stable/el/7/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm

mkdir pkgs
wget http://mirror.centos.org/centos/7/extras/x86_64/Packages/${PACKNAME}-rh-${VERSION}-${RELEASE}.centos.noarch.rpm -O pkgs/${PACKNAME}-rh-${VERSION}-${RELEASE}.centos.noarch.rpm 

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el7.x86_64.rpm ... exiting"
        exit 1
fi

wget http://vault.centos.org/7.9.2009/extras/Source/SPackages/${PACKNAME}-rh-${VERSION}-${RELEASE}.el7.centos.src.rpm -O pkgs/${PACKNAME}-rh-${VERSION}-${RELEASE}.el7.centos.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-rh-${VERSION}-${RELEASE}.el7.centos.src.rpm ... exiting"
        exit 1
fi

wget http://mirror.centos.org/centos/7/extras/x86_64/Packages/${VERSION}-${RELEASE}.el7.centos.noarch.rpm -O pkgs/${VERSION}-${RELEASE}.el7.centos.noarch.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${VERSION}-${RELEASE}.el7.centos.noarch.rpm ... exiting"
        exit 1
fi

wget http://vault.centos.org/7.9.2009/extras/Source/SPackages/${VERSION}-${RELEASE}.el7.centos.src.rpm -O pkgs/${VERSION}-${RELEASE}.el7.centos.src.rpm 

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${VERSION}-${RELEASE}.el7.centos.src.rpm ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/${PACKNAME}*.rpm
f_rsync_iso pkgs/${PACKNAME}*.rpm
rm -rf pkgs

# Update sdk7 repo
f_rupdaterepo ${REPODIR}


#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.9"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="arp-scan"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

#list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.src.rpm 
#                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
#                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
#                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm" 
#
#if [ "x$1" != "xforce" ]; then
#        f_check "${list_of_packages}"
#        if [ $? -eq 0 ]; then
#                # the rpms exist and we don't need to create again
#                exit 0
#        fi
#fi

# First we need to download source
mkdir SOURCES
mkdir pkgs
wget http://pkgs.repoforge.org/arp-scan/${PACKNAME}-${VERSION}-${RELEASE}.rf.src.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.rf.src.rpm


# with it, we can create rest of packages
/usr/bin/mock -r sdk7 \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?

# cleaning
rm -rf SOURCES

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
#f_rsync_repo pkgs/*.rpm
#f_rsync_iso pkgs/${PACKNAME}-${VERSION}*.el7.centos.x86_64.rpm
#rm -rf pkgs

# Update sdk7 repo
#f_rupdaterepo


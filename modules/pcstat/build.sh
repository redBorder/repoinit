#!/bin/bash

source build_common.sh

VERSION=${VERSION:="0.0.1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="pcstat"}

# First we need to download source
mkdir SOURCES
mkdir pkgs
wget https://github.com/tobert/pcstat/releases/download/v0.0.1/pcstat_0.0.1_x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm

# sync to cache and repo
f_rsync_repo pkgs/${PACKNAME}*.rpm
f_rsync_iso pkgs/${PACKNAME}*.rpm
rm -rf pkgs

# Update sdk7 repo
f_rupdaterepo ${REPODIR}

#!/bin/bash

source build_common.sh

VERSION=${VERSION:="0.12.6-1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="wkhtmltopdf"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}.el7.x86_64.rpm 
                  ${CACHEDIR}/${PACKNAME}-${VERSION}.el7.x86_64.rpm
                 "
if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir pkgs
# wkhtmltopdf rpms

wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.centos7.x86_64.rpm-O pkgs/${PACKNAME}-${VERSION}.el7.x86_64.rpm

f_rsync_repo pkgs/*.rpm
f_rsync_iso pkgs/*.rpm
rm -rf pkgs

# Update sdk7 repo
f_rupdaterepo ${REPODIR}

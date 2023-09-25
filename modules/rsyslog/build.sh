#!/bin/bash

source build_common.sh

VERSION=${VERSION:="8.2001.0-1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="rsyslog"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}.el7.x86_64.rpm 
                  ${CACHEDIR}/${PACKNAME}-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-${VERSION}.el7.src.rpm 
                  ${CACHEDIR}/${PACKNAME}-${VERSION}.el7.src.rpm 
                  ${REPODIR}/${PACKNAME}-${VERSION}.el7.src.rpm
                  ${CACHEDIR}/${PACKNAME}-${VERSION}.el7.src.rpm
                  ${REPODIR}/${PACKNAME}-mmnormalize-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-mmnormalize-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-mmjsonparse-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-mmjsonparse-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/libfastjson4-0.99.9-1.el7.src.rpm
                  ${CACHEDIR}/libfastjson4-0.99.9-1.el7.src.rpm
                  ${REPODIR}/libfastjson4-0.99.9-1.el7.x86_64.rpm
                  ${CACHEDIR}/libfastjson4-0.99.9-1.el7.x86_64.rpm
                  ${REPODIR}/libestr-0.1.11-1.el7.src.rpm
                  ${CACHEDIR}/libestr-0.1.11-1.el7.src.rpm
                  ${REPODIR}/libestr-0.1.11-1.el7.x86_64.rpm
                  ${CACHEDIR}/libestr-0.1.11-1.el7.x86_64.rpm
                  ${REPODIR}/liblognorm5-2.0.6-1.el7.src.rpm
                  ${CACHEDIR}/liblognorm5-2.0.6-1.el7.src.rpm
                  ${REPODIR}/liblognorm5-2.0.6-1.el7.x86_64.rpm
                  ${CACHEDIR}/liblognorm5-2.0.6-1.el7.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir pkgs
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/${PACKNAME}-${VERSION}.el7.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}.el7.x86_64.rpm
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/${PACKNAME}-${VERSION}.el7.src.rpm -O pkgs/${PACKNAME}-${VERSION}.el7.src.rpm
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/${PACKNAME}-kafka-${VERSION}.el7.x86_64.rpm -O pkgs/${PACKNAME}-kafka-${VERSION}.el7.x86_64.rpm 
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/${PACKNAME}-mmnormalize-${VERSION}.el7.x86_64.rpm -O pkgs/${PACKNAME}-mmnormalize-${VERSION}.el7.x86_64.rpm
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/${PACKNAME}-mmjsonparse-${VERSION}.el7.x86_64.rpm -O pkgs/${PACKNAME}-mmjsonparse-${VERSION}.el7.x86_64.rpm 

# Libraries for rsyslog
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/libfastjson4-0.99.9-1.el7.src.rpm -O pkgs/libfastjson4-0.99.9-1.el7.src.rpm
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/libfastjson4-0.99.9-1.el7.x86_64.rpm -O pkgs/libfastjson4-0.99.9-1.el7.x86_64.rpm
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/libestr-0.1.11-1.el7.src.rpm -O pkgs/libestr-0.1.11-1.el7.src.rpm
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/libestr-0.1.11-1.el7.x86_64.rpm -O pkgs/libestr-0.1.11-1.el7.x86_64.rpm

# Libraries for rsyslog-mmjsonparse
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/liblognorm5-2.0.6-1.el7.src.rpm -O pkgs/liblognorm5-2.0.6-1.el7.src.rpm
wget http://rpms.adiscon.com/v8-stable/epel-7/x86_64/RPMS/liblognorm5-2.0.6-1.el7.x86_64.rpm -O pkgs/liblognorm5-2.0.6-1.el7.x86_64.rpm

# sync to cache and repo
#f_rsync_repo pkgs/${PACKNAME}*.rpm
#f_rsync_iso pkgs/${PACKNAME}*.rpm
f_rsync_repo pkgs/*.rpm
f_rsync_iso pkgs/*.rpm
rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}

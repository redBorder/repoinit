#!/bin/bash

source build_common.sh

VERSION=${VERSION:="8.2308.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="rsyslog"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm
                  ${REPODIR_SRPMS}/libfastjson4-1.2304.0-1.el9.src.rpm
                  ${REPODIR_SRPMS}/libestr-0.1.11-1.el9.src.rpm
                  ${REPODIR_SRPMS}/liblognorm5-2.0.6-1.el9.src.rpm
                  ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm 
                  ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-mmnormalize-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-mmnormalize-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-mmjsonparse-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-mmjsonparse-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/libfastjson4-1.2304.0-1.el9.x86_64.rpm
                  ${CACHEDIR}/libfastjson4-1.2304.0-1.el9.x86_64.rpm
                  ${REPODIR}/libestr-0.1.11-1.el9.x86_64.rpm
                  ${CACHEDIR}/libestr-0.1.11-1.el9.x86_64.rpm
                  ${REPODIR}/liblognorm5-2.0.6-1.el9.x86_64.rpm
                  ${CACHEDIR}/liblognorm5-2.0.6-1.el9.x86_64.rpm"

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
wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm... exiting"
        exit 1
fi

wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm... exiting"
        exit 1
fi


wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/${PACKNAME}-kafka-${VERSION}-${RELEASE}.el9.x86_64.rpm -O pkgs/${PACKNAME}-kafka-${VERSION}-${RELEASE}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-kafka-${VERSION}-${RELEASE}.el9.x86_64.rpm... exiting"
        exit 1
fi

wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/${PACKNAME}-mmnormalize-${VERSION}-${RELEASE}.el9.x86_64.rpm -O pkgs/${PACKNAME}-mmnormalize-${VERSION}-${RELEASE}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-mmnormalize-${VERSION}-${RELEASE}.el9.x86_64.rpm... exiting"
        exit 1
fi

wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/${PACKNAME}-mmjsonparse-${VERSION}-${RELEASE}.el9.x86_64.rpm -O pkgs/${PACKNAME}-mmjsonparse-${VERSION}-${RELEASE}.el9.x86_64.rpm 
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-mmjsonparse-${VERSION}-${RELEASE}.el9.x86_64.rpm... exiting"
        exit 1
fi

# Libraries for rsyslog
wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/libfastjson4-1.2304.0-1.el9.src.rpm -O pkgs/libfastjson4-1.2304.0-1.el9.src.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting libfastjson4-1.2304.0-1.el9.src.rpm... exiting"
        exit 1
fi

wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/libfastjson4-1.2304.0-1.el9.x86_64.rpm -O pkgs/libfastjson4-1.2304.0-1.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting libfastjson4-1.2304.0-1.el9.x86_64.rpm... exiting"
        exit 1
fi

wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/libestr-0.1.11-1.el9.src.rpm -O pkgs/libestr-0.1.11-1.el9.src.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting libestr-0.1.11-1.el9.src.rpm... exiting"
        exit 1
fi

wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/libestr-0.1.11-1.el9.x86_64.rpm -O pkgs/libestr-0.1.11-1.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting libestr-0.1.11-1.el9.x86_64.rpm... exiting"
        exit 1
fi

# Libraries for rsyslog-mmjsonparse
wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/liblognorm5-2.0.6-1.el9.src.rpm -O pkgs/liblognorm5-2.0.6-1.el9.src.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting liblognorm5-2.0.6-1.el9.src.rpm... exiting"
        exit 1
fi

wget http://rpms.adiscon.com/v8-stable/rhel-9/x86_64/RPMS/liblognorm5-2.0.6-1.el9.x86_64.rpm -O pkgs/liblognorm5-2.0.6-1.el9.x86_64.rpm
ret=$?
        if [ $ret -ne 0 ]; then
        echo "Error in getting liblognorm5-2.0.6-1.el9.x86_64.rpm... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm
f_rsync_repo_SRPMS pkgs/*.src.rpm
f_rsync_iso pkgs/*.x86_64.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}
f_rupdaterepo ${REPODIR_SRPMS}
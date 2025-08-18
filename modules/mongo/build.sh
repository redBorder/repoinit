#!/bin/bash

source build_common.sh

VERSION=${VERSION:="7.0.1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="mongodb-org"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm 
                  ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-server-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-server-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-mongos-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-mongos-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-database-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-database-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-database-tools-extra-${VERSION}.el9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-database-tools-extra-${VERSION}.el9.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-tools-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-tools-${VERSION}-${RELEASE}.el9.x86_64.rpm
                  ${REPODIR}/mongodb-database-tools-100.8.0.x86_64.rpm
                  ${CACHEDIR}/mongodb-database-tools-100.8.0.x86_64.rpm
                  ${REPODIR}/mongodb-mongosh-2.0.1.x86_64.rpm
                  ${CACHEDIR}/mongodb-mongosh-2.0.1.x86_64.rpm"
                  
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
# Mongo rpms

wget https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/7.0/x86_64/RPMS/mongodb-org-7.0.1-1.el9.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-org-7.0.1-1.el9.x86_64.rpm... exiting"
        exit 1
fi

wget https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/7.0/x86_64/RPMS/mongodb-org-server-7.0.1-1.el9.x86_64.rpm -O pkgs/${PACKNAME}-server-${VERSION}-${RELEASE}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-org-server-7.0.1-1.el9.x86_64.rpm... exiting"
        exit 1
fi

wget https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/7.0/x86_64/RPMS/mongodb-org-mongos-7.0.1-1.el9.x86_64.rpm -O pkgs/${PACKNAME}-mongos-${VERSION}-${RELEASE}.el9.x86_64.rpm 
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-org-mongos-7.0.1-1.el9.x86_64.rpm... exiting"
        exit 1
fi

wget https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/7.0/x86_64/RPMS/mongodb-org-database-7.0.1-1.el9.x86_64.rpm -O pkgs/${PACKNAME}-database-${VERSION}-${RELEASE}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-org-database-7.0.1-1.el9.x86_64.rpm... exiting"
        exit 1
fi

wget https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/7.0/x86_64/RPMS/mongodb-org-database-tools-extra-7.0.1-1.el9.x86_64.rpm -O pkgs/${PACKNAME}-database-tools-extra-${VERSION}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-org-database-tools-extra-7.0.1-1.el9.x86_64.rpm... exiting"
        exit 1
fi

#wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-shell-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-shell-${VERSION}-${RELEASE}.el9.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/7.0/x86_64/RPMS/mongodb-org-tools-7.0.1-1.el9.x86_64.rpm -O pkgs/${PACKNAME}-tools-${VERSION}-${RELEASE}.el9.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-org-tools-7.0.1-1.el9.x86_64.rpm... exiting"
        exit 1
fi

wget https://repo.mongodb.org/yum/redhat/9Server/mongodb-org/7.0/x86_64/RPMS/mongodb-database-tools-100.8.0.x86_64.rpm -O pkgs/mongodb-database-tools-100.8.0.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-database-tools-100.8.0.x86_64.rpm... exiting"
        exit 1
fi

wget https://repo.mongodb.org/yum/redhat/8Server/mongodb-org/7.0/x86_64/RPMS/mongodb-mongosh-2.0.1.x86_64.rpm -O pkgs/mongodb-mongosh-2.0.1.x86_64.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting mongodb-mongosh-2.0.1.x86_64.rpm... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm
f_rsync_iso pkgs/*.x86_64.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}


#!/bin/bash

source build_common.sh

VERSION=${VERSION:="5.0.5-1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="mongodb-org"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}.el7.x86_64.rpm 
                  ${CACHEDIR}/${PACKNAME}-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-server-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-server-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-mongos-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-mongos-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-database-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-database-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-database-tools-extra-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-database-tools-extra-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-shell-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-shell-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/${PACKNAME}-tools-${VERSION}.el7.x86_64.rpm
                  ${CACHEDIR}/${PACKNAME}-tools-${VERSION}.el7.x86_64.rpm
                  ${REPODIR}/mongodb-database-tools-100.5.1.x86_64.rpm
                  ${CACHEDIR}/mongodb-database-tools-100.5.1.x86_64.rpm
                  ${REPODIR}/mongodb-mongosh-1.1.6.el7.x86_64.rpm
                  ${CACHEDIR}/mongodb-mongosh-1.1.6.el7.x86_64.rpm
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
# Mongo rpms

wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-server-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-server-${VERSION}.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-mongos-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-mongos-${VERSION}.el7.x86_64.rpm 
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-database-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-database-${VERSION}.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-database-tools-extra-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-database-tools-extra-${VERSION}.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-shell-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-shell-${VERSION}.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-org-tools-5.0.5-1.el7.x86_64.rpm -O pkgs/${PACKNAME}-tools-${VERSION}.el7.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-database-tools-100.5.1.x86_64.rpm -O pkgs/mongodb-database-tools-100.5.1.x86_64.rpm
wget https://repo.mongodb.org/yum/redhat/7Server/mongodb-org/5.0/x86_64/RPMS/mongodb-mongosh-1.1.6.el7.x86_64.rpm -O pkgs/mongodb-mongosh-1.1.6.el7.x86_64.rpm

f_rsync_repo pkgs/*.rpm
f_rsync_iso pkgs/*.rpm
rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}

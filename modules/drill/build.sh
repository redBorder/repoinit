#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.20.3"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="apache-drill"}

CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm \
                  ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm \
                  ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm"

# Check if the package already exists
if [ "x${1:-}" != "xforce" ]; then
    f_check "${list_of_packages}"
    if [ $? -eq 0 ]; then
        exit 0
    fi
fi

# Download and sync the package
URL="http://rbrepo.redborder.lan/repos/ng/latest/rhel/9/x86_64/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm"

mkdir -p pkgs
wget -q "${URL}" -O "pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm"

# Sync to cache and repo
f_rsync_repo        pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm
f_rsync_repo_SRPMS  pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm
f_rsync_iso         pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm

# Update repo metadata
echo "🧩 Actualizando metadata del repositorio..."
f_rupdaterepo "${REPODIR}"
f_rupdaterepo "${REPODIR_SRPMS}"

# Clean
rm -rf pkgs

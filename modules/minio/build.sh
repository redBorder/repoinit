#!/bin/bash

source build_common.sh

VERSION=${VERSION:="0.1.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="minio"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir SOURCES
pushd SOURCES &>/dev/null
wget --no-check-certificate https://dl.minio.io/server/minio/release/linux-amd64/minio 
popd &>/dev/null

# Now it is time to create the source rpm
/usr/bin/mock \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?

# cleaning
rm -rf SOURCES

if [ $ret -ne 0 ]; then
	echo "Error in mock stage ... exiting"
	exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/${PACKNAME}*.rpm
f_rsync_iso pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
rm -rf pkgs

# Update sdk7 repo
f_rupdaterepo ${REPODIR}


#!/bin/bash

source build_common.sh

VERSION=${VERSION:="2.3.0"}
RELEASE=${RELEASE:="5"}
PACKNAME=${PACKNAME:="slang"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-slsh-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-static-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-devel-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
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
wget https://dl.fedoraproject.org/pub/fedora/linux/development/24/Server/source/tree/Packages/s/slang-${VERSION}-${RELEASE}.fc24.src.rpm -O SOURCES/${PACKNAME}-${VERSION}-${RELEASE}.fc24.src.rpm
pushd SOURCES &>/dev/null
rpm2cpio ${PACKNAME}-${VERSION}-${RELEASE}.fc24.src.rpm | cpio -idmv
popd &>/dev/null

# Now it is time to create the source rpm
/usr/bin/mock -r sdk9 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk9 \
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
f_rsync_repo pkgs/*.rpm
f_rsync_iso pkgs/${PACKNAME}-${VERSION}*.el7.rb.x86_64.rpm
rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo


#!/bin/bash

source build_common.sh

COMMIT=${COMMIT:="3a0441ca2123b3f89d879669b7ca9c047e62c8a8"}
VERSION=${VERSION:="0.1.0"}
RELEASE=${RELEASE:="1"}
LIBVER=${LIBVER:="0"}
PACKNAME=${PACKNAME:="librd"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}
VSHORT=$(c=${COMMIT}; echo ${c:0:7})

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm 
                ${REPODIR}/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
                ${REPODIR}/${PACKNAME}-devel-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir SOURCES
wget https://github.com/edenhill/${PACKNAME}/archive/${COMMIT}/${PACKNAME}-${VERSION}-${VSHORT}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}-${VSHORT}.tar.gz

# Now it is time to create the source rpm
/usr/bin/mock -r sdk7 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
        --define "__libver ${LIBVER}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk7 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
        --define "__libver ${LIBVER}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

# cleaning
rm -rf SOURCES

# sync to cache and repo
rsync -a pkgs/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
rm -rf pkgs

# Update sdk7 repo
f_updaterepo ${REPODIR}


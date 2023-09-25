#!/bin/bash

source build_common.sh

#VERSION=${VERSION:="0.8.4"}
VERSION=${VERSION:="0.9.1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="librdkafka"}
LIBVER=${LIBVER:="1"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm 
		${REPODIR}/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
		${REPODIR}/${PACKNAME}-devel-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
		${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
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
wget https://github.com/edenhill/librdkafka/archive/${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz

# Now it is time to create the source rpm
/usr/bin/mock -r sdk9 \
	--define "__version ${VERSION}" \
	--define "__release ${RELEASE}" \
	--define "__libver ${LIBVER}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk9 \
	--define "__version ${VERSION}" \
	--define "__release ${RELEASE}" \
	--define "__libver ${LIBVER}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?

# cleaning
rm -rf SOURCES

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
#rsync -a pkgs/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm ${CACHEDIR}
#rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
f_rsync_repo pkgs/${PACKNAME}*.rpm
f_rsync_iso pkgs/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo


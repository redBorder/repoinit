#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.0.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="rbrepo"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}
VSHORT=$(c=${COMMIT}; echo ${c:0:7})

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
cp rbrepo.repo SOURCES

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
f_rsync_iso pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.noarch.rpm
rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}


#!/bin/bash

source build_common.sh

VERSION=${VERSION:="v0.20"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="secor"}
LIBVER=${LIBVER:="1"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}
CORRECT_VERSION=$(echo $VERSION | tr -d 'v')

list_of_packages="${REPODIR}/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el7.rb.src.rpm 
		${REPODIR}/${PACKNAME}${LIBVER}-${CORRECT_VERSION}-${RELEASE}.el7.rb.noarch.rpm 
		${REPODIR}/${PACKNAME}-devel-${CORRECT_VERSION}-${RELEASE}.el7.rb.noarch.rpm 
		${CACHEDIR}/${PACKNAME}${LIBVER}-${CORRECT_VERSION}-${RELEASE}.el7.rb.noarch.rpm" 

if [ "x$1" != "xforce" ]; then
	f_check "${list_of_packages}"
	if [ $? -eq 0 ]; then
		# the rpms exist and we don't need to create again
		exit 0
	fi
fi

# First we need to download source
mkdir SOURCES
git clone https://github.com/pinterest/secor.git
pushd secor &> /dev/null
git checkout ${VERSION}
popd &> /dev/null
mv secor secor-${CORRECT_VERSION}
tar czf SOURCES/secor-${CORRECT_VERSION}.tar.gz secor-${CORRECT_VERSION}
cp secor.service SOURCES/secor.service

# Now it is time to create the source rpm
/usr/bin/mock -r sdk7 \
	--define "__version ${CORRECT_VERSION}" \
	--define "__release ${RELEASE}" \
	--define "__libver ${LIBVER}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk7 \
	--define "__version ${CORRECT_VERSION}" \
	--define "__release ${RELEASE}" \
	--define "__libver ${LIBVER}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?

# cleaning
rm -rf SOURCES
rm -rf secor-${CORRECT_VERSION}

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
#rsync -a pkgs/${PACKNAME}${LIBVER}-${CORRECT_VERSION}-${RELEASE}.el7.centos.x86_64.rpm ${CACHEDIR}
#rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
#f_rsync_repo pkgs/${PACKNAME}*.rpm
#f_rsync_iso pkgs/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el7.centos.x86_64.rpm
#rm -rf pkgs

# Update sdk7 repo
#f_updaterepo


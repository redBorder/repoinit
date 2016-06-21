#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.27.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="rvm"}
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
wget --no-check-certificate https://github.com/rvm/${PACKNAME}/archive/${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz
wget --no-check-certificate https://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.4.tar.bz2 -O SOURCES/ruby-2.2.4.tar.bz2
cp rvmrc rvm.sh SOURCES

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
f_rsync_iso pkgs/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
f_rsync_repo pkgs/${PACKNAME}*.rpm  
rm -rf pkgs

# Update sdk7 repo
f_rupdaterepo


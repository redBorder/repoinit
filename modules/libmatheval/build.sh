#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.1.11"}
RELEASE=${RELEASE:="3"}
PACKNAME=${PACKNAME:="libmatheval"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
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
rm -rf SOURCES
rm -rf pkgs
mkdir SOURCES
mkdir pkgs
wget http://ftp.gnu.org/gnu/${PACKNAME}/${PACKNAME}-${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}/${PACKNAME}-${VERSION}.tar.gz... exiting"
        exit 1
fi

# Now it is time to create the source rpm
/usr/bin/mock -r sdk7 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk7 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm
f_rsync_repo_SRPMS pkgs/*.src.rpm
f_rsync_iso pkgs/*.x86_64.rpm

rm -rf pkgs
rm -rf SOURCES

# Update sdk9 repo
f_rupdaterepo ${REPODIR}
f_rupdaterepo $REPODIR_SRPMS


#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.7.6"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="cookbook-cron"}
LIBVER=${LIBVER:="1"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.src.rpm 
		${REPODIR}/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el9.rb.noarch.rpm 
		${CACHEDIR}/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el9.rb.noarch.rpm" 

if [ "x$1" != "xforce" ]; then
	f_check "${list_of_packages}"
	if [ $? -eq 0 ]; then
		# the rpms exist and we don't need to create again
		exit 0
	fi
fi

# First we need to download source
mkdir SOURCES
wget https://github.com/chef-cookbooks/cron/archive/v${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting v${VERSION}.tar.gz ... exiting"
        exit 1
fi

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
f_rsync_repo pkgs/*.noarch.rpm
f_rsync_repo_SRPMS pkgs/*.src.rpm
f_rsync_iso pkgs/*.noarch.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo $REPODIR
f_rupdaterepo $REPODIR_SRPMS


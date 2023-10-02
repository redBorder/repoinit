#!/bin/bash

source build_common.sh

COMMIT=${COMMIT:="b5dc6128058c53b9be0f8244db143cd34cfb32fe"}
VERSION=${VERSION:="1.2.0"}
RELEASE=${RELEASE:="1"}
LIBVER=${LIBVER:="0"}
PACKNAME=${PACKNAME:="librb-http"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}
VSHORT=$(c=${COMMIT}; echo ${c:0:7})

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.src.rpm 
                ${REPODIR}/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}${LIBVER}-debuginfo-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-devel-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debugsource-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}${LIBVER}-debuginfo-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-devel-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-debugsource-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm"

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
# wget http://{{your_host}}/api/v3/projects/{{project_id}}/repository/archive?sha={{commit_sha}} --header='PRIVATE-TOKEN: {{private_token}}'
wget --no-check-certificate https://gitlab.redborder.lan/core-developers/${PACKNAME}/repository/archive.tar.gz?ref=${VERSION} --header='PRIVATE-TOKEN:oDRezN5gFLgBB6nWsMZU' -O SOURCES/${PACKNAME}-${VERSION}-${VSHORT}.tar.gz
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}/repository/archive.tar.gzz... exiting"
        exit 1
fi

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
f_rupdaterepo ${REPODIR_SRPMS}


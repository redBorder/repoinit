#!/bin/bash

source build_common.sh

COMMIT=${COMMIT:="77fd6ca17de64470ff7295db24b27eef0daba0cd"}
VERSION=${VERSION:="1.0.0"}
RELEASE=${RELEASE:="1"}
LIBVER=${LIBVER:="0"}
PACKNAME=${PACKNAME:="n2kafka"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}
VSHORT=$(c=${COMMIT}; echo ${c:0:7})

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir SOURCES
# wget http://{{your_host}}/api/v3/projects/{{project_id}}/repository/archive?sha={{commit_sha}} --header='PRIVATE-TOKEN: {{private_token}}'
wget --no-check-certificate https://gitlab.redborder.lan/dfernandez.ext/${PACKNAME}/repository/archive.tar.gz?ref=redborder --header='PRIVATE-TOKEN:oDRezN5gFLgBB6nWsMZU' -O SOURCES/${PACKNAME}-${VERSION}-${VSHORT}.tar.gz

exit 0

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
f_rsyn_iso pkgs/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.centos.x86_64.rpm
rm -rf pkgs

# Update sdk7 repo
f_rupdaterepo ${REPODIR}


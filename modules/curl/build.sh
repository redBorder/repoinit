#!/bin/bash

source build_common.sh

VERSION=${VERSION:="7.76.1"}
RELEASE=${RELEASE:="23"}
PACKNAME=${PACKNAME:="curl"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm
                ${REPODIR}/lib${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm
                ${REPODIR}/lib${PACKNAME}-devel-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm
                ${CACHEDIR}/lib${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm
                ${CACHEDIR}/lib${PACKNAME}-devel-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
#mkdir SOURCES
# wget http://nervion.us.es/city-fan/yum-repo/rhel7/source/curl-${VERSION}-1.0.cf.rhel7.src.rpm -O SOURCES/curl-${VERSION}-1.0.cf.rhel7.src.rpm
# pushd SOURCES &>/dev/null
# rpm2cpio curl-${VERSION}-1.0.cf.rhel7.src.rpm | cpio -idmv
# popd &>/dev/null

# # Now it is time to create the source rpm
# /usr/bin/mock -r sdk9 \
#         --define "__version ${VERSION}" \
#         --define "__release ${RELEASE}" \
# 	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# # with it, we can create rest of packages
# /usr/bin/mock -r sdk9 \
#         --define "__version ${VERSION}" \
#         --define "__release ${RELEASE}" \
# 	--resultdir=pkgs --rebuild pkgs/curl*.src.rpm
#
# ret=$?
# if [ $ret -ne 0 ]; then
#         echo "Error in mock stage ... exiting"
#         exit 1
# fi
#
# cleaning
#rm -rf SOURCES


rm -rf pkgs
mkdir pkgs

wget https://mirrors.vcea.wsu.edu/rocky/9/devel/x86_64/os/Packages/c/${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm -O pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm 

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm m ... exiting"
        exit 1
fi

wget https://mirrors.vcea.wsu.edu/rocky/9/devel/x86_64/os/Packages/l/lib${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm -O pkgs/lib${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting lib${PACKNAME}-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm ... exiting"
        exit 1
fi

wget https://mirrors.vcea.wsu.edu/rocky/9/devel/x86_64/os/Packages/l/lib${PACKNAME}-devel-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm -O pkgs/lib${PACKNAME}-devel-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting lib${PACKNAME}-devel-${VERSION}-${RELEASE}.el9_2.2.x86_64.rpm ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.rpm
f_rsync_iso pkgs/*.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo $REPODIR



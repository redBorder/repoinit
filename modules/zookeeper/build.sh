#!/bin/bash

source build_common.sh

VERSION=${VERSION:="3.4.12"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="zookeeper"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${REPODIR}/lib${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${REPODIR}/lib${PACKNAME}-devel-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/lib${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/lib${PACKNAME}-devel-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
rm -rf pkgs
rm -rf SOURCES
mkdir -p SOURCES

URL="https://archive.apache.org/dist/zookeeper/zookeeper-${VERSION}/zookeeper-${VERSION}.tar.gz"
wget ${URL} -O SOURCES/${PACKNAME}-${VERSION}.tar.gz

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting zookeeper-${VERSION}/zookeeper-${VERSION}.tar.gz... exiting"
        exit 1
fi

wget https://github.com/redBorder/zookeeper-el7-rpm/archive/master.tar.gz -O SOURCES/zookeeper-el7-rpm.tar.gz

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting zookeeper-el7-rpm.tar.gz... exiting"
        exit 1
fi

pushd SOURCES &>/dev/null
tar xzf zookeeper-el7-rpm.tar.gz
mv ${PACKNAME}-${VERSION}.tar.gz zookeeper-el7-rpm-master
cp ../zookeeper.sh zookeeper-el7-rpm-master/
cp ../patches/* zookeeper-el7-rpm-master/
popd &>/dev/null

# Now it is time to create the source rpm
/usr/bin/mock -r sdk9 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES/zookeeper-el7-rpm-master

# with it, we can create rest of packages
/usr/bin/mock -r sdk9 \
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

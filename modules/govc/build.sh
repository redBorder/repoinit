#!/bin/bash

VERSION=${VERSION:="0.54.1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="govc"}

# First we need to download source
rm -rf SOURCES
rm -rf pkgs
mkdir SOURCES
mkdir pkgs
wget --no-check-certificate https://github.com/vmware/govmomi/releases/download/v${VERSION}/govc_Linux_x86_64.tar.gz -O SOURCES/govc_Linux_x86_64.tar.gz
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting govc_Linux_x86_64.tar.gz... exiting"
        exit 1
fi

pushd SOURCES &>/dev/null
tar -xzf govc_Linux_x86_64.tar.gz
rm -f govc_Linux_x86_64.tar.gz
popd &>/dev/null

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
if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# Clean up build sources, but keep build results in pkgs/
rm -rf SOURCES

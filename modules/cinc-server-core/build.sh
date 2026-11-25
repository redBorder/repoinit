#!/bin/bash

# Cinc Server (Apache 2.0 build of Chef Infra Server). Used by redborder-cinc-server.
# Cinc has no yum repository: the RPM is downloaded from downloads.cinc.sh and pushed to ours.
# To upgrade, change VERSION, RELEASE and SHA256 together (SHA256 is the "sha256" field of
# ${DOWNLOAD_URL}.metadata.json).

source build_common.sh

VERSION=${VERSION:="15.10.127"}
RELEASE=${RELEASE:="1"}
SHA256=${SHA256:="4423a3928f0e252fbc472c2335e079c60fbbd2a0e6eac7e6504fd732e42671c7"}
PACKNAME=${PACKNAME:="cinc-server-core"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}

RPMNAME="${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm"
DOWNLOAD_URL="https://downloads.cinc.sh/files/stable/cinc-server/${VERSION}/el/9/${RPMNAME}"

list_of_packages="${REPODIR}/${RPMNAME}
                ${CACHEDIR}/${RPMNAME}"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

rm -rf pkgs
mkdir pkgs

wget ${DOWNLOAD_URL} -O pkgs/${RPMNAME} && wget ${DOWNLOAD_URL}.metadata.json -O pkgs/${RPMNAME}.metadata.json
if [ $? -ne 0 ]; then
        echo "Error in getting ${RPMNAME} ... exiting"
        rm -rf pkgs
        exit 1
fi

# Verify the download against the pinned checksum and the one published by Cinc
sha256=$(sha256sum pkgs/${RPMNAME} | cut -d' ' -f1)
if [ "x${sha256}" != "x${SHA256}" ]; then
        echo "Error: ${RPMNAME} sha256 is ${sha256}, expected ${SHA256} ... exiting"
        rm -rf pkgs
        exit 1
fi
if ! grep -q "\"sha256\": *\"${SHA256}\"" pkgs/${RPMNAME}.metadata.json; then
        echo "Error: ${SHA256} is not the sha256 published in ${RPMNAME}.metadata.json ... exiting"
        rm -rf pkgs
        exit 1
fi
rm -f pkgs/${RPMNAME}.metadata.json

# sync to cache and repo
f_rsync_repo pkgs/*.rpm
f_rsync_iso pkgs/*.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo $REPODIR

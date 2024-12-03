#!/bin/bash

source build_common.sh

VERSION=${VERSION:="0.1.1"}
RELEASE=${RELEASE:="2"}
MINIORELEASE=${MINIORELEASE:="20230125001954"}
PACKNAME=${PACKNAME:="minio"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}

if [ "x${DEVEL}" == "x" ]; then
  REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
  REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}
else
  REPODIR=${REPODIR:="/repos/ng/devel/${DEVEL}/rhel/9/x86_64"}
  REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/devel/${DEVEL}/rhel/9/SRPMS"}
fi

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.src.rpm 
                  ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                  ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm"

echo 'Starting to build minio'
if [ "x$1" != "xforce" ]; then
  f_check "${list_of_packages}"
  if [ $? -eq 0 ]; then
    echo the rpms exist and we do not need to create again
    exit 0
  fi
fi

# First we need to download source
rm -rf SOURCES
rm -rf pkgs
mkdir SOURCES
mkdir pkgs
pushd SOURCES &>/dev/null

MINIO_FILE="${PACKNAME}-${MINIORELEASE}.0.0.x86_64.rpm"
wget --no-check-certificate "https://dl.minio.io/server/minio/release/linux-amd64/archive/${MINIO_FILE}"
rpm2cpio ${PACKNAME}-${MINIORELEASE}.0.0.x86_64.rpm | cpio -idmv && mv /usr/local/bin/minio .    #Extract the executable and move it to SOURCES
rm -f /etc/systemd/system/minio.service                                                   #Remove other extracted files that we don't want from our system
popd &>/dev/null
cp minio.service SOURCES/minio.service

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
if [ $ret -ne 0 ]; then
	echo "Error in mock stage ... exiting"
	exit 1
fi

# sync to cache and repo
echo 'Sync rpm'
if [ "x${DEVEL}" == "x" ]; then
  f_rsync_repo pkgs/*.x86_64.rpm
  f_rsync_repo_SRPMS pkgs/*.src.rpm
  f_rsync_iso pkgs/*.x86_64.rpm
else
  f_rsync_devel_repo pkgs/*.x86_64.rpm
  f_rsync_devel_repo_SRPMS pkgs/*.src.rpm
  # f_rsync_iso pkgs/*.x86_64.rpm
fi

echo Removing packages from local
rm -rf pkgs
rm -rf SOURCES

# Update sdk9 repo
f_rupdaterepo ${REPODIR}
f_rupdaterepo ${REPODIR_SRPMS}


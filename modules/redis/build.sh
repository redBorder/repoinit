#!/bin/bash

source build_common.sh

RELEASE=${RELEASE:="1"}
VERSION=${VERSION:="8.0.3"}
PACKNAME=${PACKNAME:="redis"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm 
                  ${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm"

if [ "x$1" != "xforce" ]; then
  f_check "${list_of_packages}"
  if [ $? -eq 0 ]; then
    # the rpms exist and we don't need to create again
    exit 0
  fi
fi

LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RPM_DIR="$LOCAL_DIR/rpmbuild"

# Install dependencies
sudo yum install -y rpm-build rpmdevtools gcc make systemd-devel

# Clean previous builds and create custom rpmbuild directory structure
rm -rf "$RPM_DIR"
mkdir -p "$RPM_DIR"/{SOURCES,SPECS,BUILD,RPMS,SRPMS}

# Download Redis source
wget https://download.redis.io/releases/redis-$VERSION.tar.gz -P "$RPM_DIR/SOURCES/"

# Copy files to build package
cp "$LOCAL_DIR"/LICENSE "$RPM_DIR/SOURCES/"
cp "$LOCAL_DIR"/redis.spec "$RPM_DIR/SPECS/"

# Build RPM
cd "$RPM_DIR/SPECS"
rpmbuild --define "_topdir $RPM_DIR" -ba redis.spec

# Create and copy RPMs to pkgs
mkdir -p "$LOCAL_DIR/pkgs"
cp "$RPM_DIR"/RPMS/x86_64/redis-$VERSION*.rpm "$LOCAL_DIR/pkgs/"
cp "$RPM_DIR"/SRPMS/redis-*.rpm "$LOCAL_DIR/pkgs/"

# Clean build directory
rm -rf "$RPM_DIR"

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm
f_rsync_repo_SRPMS pkgs/*.src.rpm

rm -rf pkgs

# Update sdk9 repo
f_rupdaterepo ${REPODIR}
f_rupdaterepo ${REPODIR_SRPMS}

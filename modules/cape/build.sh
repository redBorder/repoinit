#!/bin/bash

source build_common.sh

# --- Package Configuration ---
VERSION=${VERSION:="0.0.1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="cape"}
LIBVER=${LIBVER:="1"}
# This is the version that the script will use to search for existing RPMs.
CORRECT_VERSION="${VERSION}" 

# --- Repository Configuration ---
GIT_URL="https://github.com/redBorder/redborder-cape.git"
BRANCH="redborder"
GITNAME="redborder-cape"

# --- RHEL 9 Directories ---
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

# --- Package list ---
list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el9.rb.src.rpm 
		${REPODIR}/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
		${REPODIR}/${PACKNAME}-debuginfo-${CORRECT_VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
		${CACHEDIR}/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el9.rb.x86_64.rpm
		${CACHEDIR}/${PACKNAME}-debuginfo-${CORRECT_VERSION}-${RELEASE}.el9.rb.x86_64.rpm" 

if [ "x$1" != "xforce" ]; then
	f_check "${list_of_packages}"
	if [ $? -eq 0 ]; then
		# the rpms exist and we don't need to create again
		exit 0
	fi
fi

# Download
rm -rf SOURCES ${GITNAME}
mkdir SOURCES

# We clone only the branch we are interested in
git clone -b "${BRANCH}" --depth 1 "${GIT_URL}" "${GITNAME}"

# Rename so that the tarball has the format expected by the .spec
mv "${GITNAME}" "${PACKNAME}-${VERSION}"
tar czf "SOURCES/${PACKNAME}-${VERSION}.tar.gz" "${PACKNAME}-${VERSION}"

# Copy the systemd unit files
cp cape.service cape-rooter.service cape-processor.service cape-web.service SOURCES/

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
f_rsync_repo pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
f_rsync_iso pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm

# cleaning
rm -rf SOURCES
rm -rf pkgs
rm -rf ${PACKNAME}-${VERSION}

# Update sdk9 repo
f_rupdaterepo ${REPODIR}

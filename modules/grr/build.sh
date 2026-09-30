#!/bin/bash

source build_common.sh

VERSION=${VERSION:="3.4.7.1"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="grr"}
FULLPACKNAME=${FULLPACKNAME:="grr"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

# First we need to download source
URL="https://github.com/redBorder/${PACKNAME}/archive/redborder.tar.gz"
mkdir SOURCES
wget ${URL} -O SOURCES/${PACKNAME}-${VERSION}.tar.gz

## ----- Develop mode ------
#
#GIT_URL="https://github.com/redBorder/grr.git"
#BRANCH="feature/#26674_Integrate_grr_endpoints"
#GITNAME="redborder-grr"
#
## We clone only the branch we are interested in
#git clone -b "${BRANCH}" --depth 1 "${GIT_URL}" "${GITNAME}"
#
## Rename so that the tarball has the format expected by the .spec
#mv "${GITNAME}" "${PACKNAME}-${VERSION}"
#tar czf "SOURCES/${PACKNAME}-${VERSION}.tar.gz" "${PACKNAME}-${VERSION}"
#
## ----- END Develop mode ------


list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm \
${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm \
${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm"
#
if [ "x$1" != "xforce" ]; then
	f_check "${list_of_packages}"
	if [ $? -eq 0 ]; then
		# the rpms exist and we don't need to create again
		exit 0
	fi
fi

echo "Copying service files to SOURCES..."
cp grr-fleetspeak.service SOURCES/
cp grr-adminui.service SOURCES/
cp grr-frontend.service SOURCES/
cp grr-worker.service SOURCES/
cp requirements.txt SOURCES/
#
# Now it is time to create the source rpm
/usr/bin/mock -r sdk9 \
	--define "__version ${VERSION}" \
	--define "__release ${RELEASE}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES
echo "Finish"
#
## with it, we can create rest of packages
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
#f_rsync_repo pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm
#f_rsync_iso pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm
#
#rm -rf SOURCES pkgs ${FULLPACKNAME}-${VERSION}
#
## Update sdk9 repo
#f_rupdaterepo ${REPODIR}

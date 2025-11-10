#!/bin/bash

source build_common.sh

VERSION=${VERSION:="0.0.1"}
RELEASE=${RELEASE:="1"}
GITNAME=${GITNAME:="CAPEv2"}
PACKNAME=${PACKNAME:="cape"}
LIBVER=${LIBVER:="1"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}
LAST_STABLE_COMMIT=${LAST_STABLE_COMMIT:="cfc97e71ad538366f5d87d36a0116c27dcc72988"} # Last tested commit

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el7.rb.src.rpm 
		${REPODIR}/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
		${REPODIR}/${PACKNAME}-debuginfo-${CORRECT_VERSION}-${RELEASE}.el7.rb.x86_64.rpm 
		${CACHEDIR}/${PACKNAME}-${CORRECT_VERSION}-${RELEASE}.el7.rb.x86_64.rpm
		${CACHEDIR}/${PACKNAME}-debuginfo-${CORRECT_VERSION}-${RELEASE}.el7.rb.x86_64.rpm" 

if [ "x$1" != "xforce" ]; then
	f_check "${list_of_packages}"
	if [ $? -eq 0 ]; then
		# the rpms exist and we don't need to create again
		exit 0
	fi
fi

# First we need to download source
# rm -rf SOURCES
# mkdir SOURCES
# git clone https://github.com/kevoreilly/CAPEv2.git
# pushd ${GITNAME} &> /dev/null
# git checkout ${LAST_STABLE_COMMIT}
# popd &> /dev/null
# mv ${GITNAME} ${PACKNAME}-${VERSION}
# tar czf SOURCES/${PACKNAME}-${VERSION}.tar.gz ${PACKNAME}-${VERSION}
cp cape.service SOURCES/cape.service
cp cape-rooter.service SOURCES/cape-rooter.service
cp cape-processor.service SOURCES/cape-processor.service
cp cape-web.service SOURCES/cape-web.service

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
# f_rsync_repo pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm
# f_rsync_iso pkgs/${PACKNAME}-${VERSION}-${RELEASE}.el9.x86_64.rpm

# cleaning
# rm -rf SOURCES
# rm -rf pkgs
# rm -rf ${PACKNAME}-${VERSION}

# Update sdk9 repo
# f_rupdaterepo ${REPODIR}

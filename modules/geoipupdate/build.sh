#!/bin/bash

# Packets generated:
#   GeoIP-1.6.9-2.el7.rb.x86_64.rpm
#   GeoIP-GeoLite-data-2016.10-1.el7.rb.noarch.rpm
#   GeoIP-GeoLite-data-extra-2016.10-1.el7.rb.noarch.rpm
#   geoipupdate-2.2.2-2.el7.rb.x86_64.rpm
#   geoipupdate-cron-2.2.2-2.el7.rb.noarch.rpm

source build_common.sh

VERSION=${VERSION:="2.2.2"}
RELEASE=${RELEASE:="2"}
PACKNAME=${PACKNAME:="geoipupdate"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.src.rpm
				${REPODIR_SRPMS}/GeoIP-GeoLite-data-2016.05-1.el9.rb.src.rpm
				${REPODIR_SRPMS}/GeoIP-1.6.9-2.el9.rb.src.rpm
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-debugsource-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${REPODIR}/${PACKNAME}-cron-${VERSION}-${RELEASE}.el9.rb.noarch.rpm 
                ${REPODIR}/${PACKNAME}-cron6-${VERSION}-${RELEASE}.el9.rb.noarch.rpm 
				${REPODIR}/GeoIP-GeoLite-data-2016.05-1.el9.rb.noarch.rpm
				${REPODIR}/GeoIP-GeoLite-data-extra-2016.05-1.el9.rb.noarch.rpm
                ${REPODIR}/GeoIP-1.6.9-2.el9.rb.x86_64.rpm
                ${REPODIR}/GeoIP-debuginfo-1.6.9-2.el9.rb.x86_64.rpm
                ${REPODIR}/GeoIP-debugsource-1.6.9-2.el9.rb.x86_64.rpm
                ${REPODIR}/GeoIP-devel-1.6.9-2.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-debuginfo-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-debugsource-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm 
                ${CACHEDIR}/${PACKNAME}-cron-${VERSION}-${RELEASE}.el9.rb.noarch.rpm 
                ${CACHEDIR}/${PACKNAME}-cron6-${VERSION}-${RELEASE}.el9.rb.noarch.rpm
				${CACHEDIR}/GeoIP-GeoLite-data-2016.05-1.el9.rb.noarch.rpm
				${CACHEDIR}/GeoIP-GeoLite-data-extra-2016.05-1.el9.rb.noarch.rpm
                ${CACHEDIR}/GeoIP-1.6.9-2.el9.rb.x86_64.rpm
				${CACHEDIR}/GeoIP-debuginfo-1.6.9-2.el9.rb.x86_64.rpm
                ${CACHEDIR}/GeoIP-debugsource-1.6.9-2.el9.rb.x86_64.rpm
                ${CACHEDIR}/GeoIP-devel-1.6.9-2.el9.rb.x86_64.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
rm -rf SOURCES
rm -rf pkgs
mkdir SOURCES
mkdir pkgs
wget https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/24/Everything/source/tree/Packages/g/geoipupdate-2.2.2-2.fc24.src.rpm -O SOURCES/geoipupdate-2.2.2-2.fc24.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting geoipupdate-2.2.2-2.fc24.src.rpm... exiting"
        exit 1
fi

wget https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/24/Everything/source/tree/Packages/g/GeoIP-1.6.9-2.fc24.src.rpm -O SOURCES/GeoIP-1.6.9-2.fc24.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting GeoIP-1.6.9-2.fc24.src.rpm... exiting"
        exit 1
fi

wget https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/24/Everything/source/tree/Packages/g/GeoIP-GeoLite-data-2016.05-1.fc24.src.rpm -O SOURCES/GeoIP-GeoLite-data-2016.10-1.fc26.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting GeoIP-GeoLite-data-2016.10-1.fc26.src.rpm... exiting"
        exit 1
fi

# with it, we can create rest of packages
/usr/bin/mock -r sdk9 \
	--resultdir=pkgs --rebuild SOURCES/geoipupdate-2.2.2-2.fc24.src.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in mock stage of geoipupdate ... exiting"
        exit 1
fi

/usr/bin/mock -r sdk9 \
	--resultdir=pkgs --rebuild SOURCES/GeoIP-1.6.9-2.fc24.src.rpm
ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in mock stage GeoIP... exiting"
        exit 1
fi
/usr/bin/mock -r sdk9 \
	--resultdir=pkgs --rebuild SOURCES/GeoIP-GeoLite-data-2016.10-1.fc26.src.rpm

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in mock stage GeoIP-GeoLite... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.x86_64.rpm pkgs/*.noarch.rpm
f_rsync_repo_SRPMS pkgs/*.src.rpm
f_rsync_iso pkgs/*.x86_64.rpm pkgs/*.noarch.rpm

rm -rf pkgs
rm -rf SOURCES

# Update sdk9 repo
f_rupdaterepo ${REPODIR}
f_rupdaterepo ${REPODIR_SRPMS}


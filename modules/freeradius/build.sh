#!/bin/bash

source build_common.sh

#COMMIT=${COMMIT:="89fe893f63d4ce0f5fc32c3f8dab75fa94497d08"}
VERSION=${VERSION:="2.2.9"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="freeradius"}
CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-rb-${VERSION}-${RELEASE}.el9.rb.src.rpm
                ${REPODIR}/${PACKNAME}-rb-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-debuginfo-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-kafka-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-krb5-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-ldap-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-mysql-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-perl-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-postgresql-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-python-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-unixODBC-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${REPODIR}/${PACKNAME}-rb-utils-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-debuginfo-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-kafka-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-krb5-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-ldap-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-mysql-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-perl-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-postgresql-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-python-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-unixODBC-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm
                ${CACHEDIR}/${PACKNAME}-rb-utils-${VERSION}-${RELEASE}.el9.rb.x86_64.rpm"


if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
rm -rf SOURCES
mkdir -p SOURCES
wget ftp://ftp.freeradius.org/pub/freeradius/old/${PACKNAME}-server-${VERSION}.tar.gz -O SOURCES/${PACKNAME}-server-${VERSION}.tar.gz

ret=$?
if [ $ret -ne 0 ]; then
        echo "Error in getting ${PACKNAME}-server-${VERSION}.tar.gz ... exiting"
        exit 1
fi

cp patches/* SOURCES

# Now it is time to create the source rpm
/usr/bin/mock -r sdk9 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --buildsrpm --spec=freeradius.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk9 \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?

# cleaning
rm -rf SOURCES

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_repo pkgs/*.el9.rb.x86_64.rpm
f_rsync_repo_SRPMS pkgs/*.src.rpm
f_rsync_iso pkgs/*.el9.rb.x86_64.rpm

rm -rf pkgs
rm -rf SOURCES

# Update sdk9 repo
f_rupdaterepo $REPODIR
f_rupdaterepo $REPODIR_SRPMS

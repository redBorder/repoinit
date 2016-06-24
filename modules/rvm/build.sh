#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.27.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="rvm"}
BUNDLER_VERSION=${BUNDLER_VERSION:="1.12.5"}
RUBYGEMS_VERSION=${RUBYGEMS_VERSION:="2.4.8"}
RUBY_VERSION=${RUBY_VERSION:="2.2.4"}
CACHEDIR=${CACHEDIR:="/isos/redBorder"}
REPODIR=${REPODIR:="/repos/redBorder"}

list_of_packages="${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.src.rpm 
                ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.noarch.rpm 
                ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el7.rb.noarch.rpm"

if [ "x$1" != "xforce" ]; then
        f_check "${list_of_packages}"
        if [ $? -eq 0 ]; then
                # the rpms exist and we don't need to create again
                exit 0
        fi
fi

# First we need to download source
mkdir SOURCES
wget --no-check-certificate https://github.com/rvm/${PACKNAME}/archive/${VERSION}.tar.gz -O SOURCES/${PACKNAME}-${VERSION}.tar.gz
#wget --no-check-certificate https://ftp.ruby-lang.org/pub/ruby/2.2/ruby-${RUBY_VERSION}.tar.bz2 -O SOURCES/ruby-${RUBY_VERSION}.tar.bz2
#wget --no-check-certificate https://rubygems.org/downloads/bundler-${BUNDLER_VERSION}.gem -O SOURCES/bundler-${BUNDLER_VERSION}.gem
#wget --no-check-certificate https://rubygems.org/downloads/bundle-0.0.1.gem -O SOURCES/bundle-0.0.1.gem
#wget --no-check-certificate https://rubygems.org/rubygems/rubygems-${RUBYGEMS_VERSION}.tgz -O SOURCES/rubygems-${RUBYGEMS_VERSION}.tar.gz
cp rvmrc rvm.sh SOURCES

# Now it is time to create the source rpm
/usr/bin/mock \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--define "__rubyversion ${RUBY_VERSION}" \
	--define "__bundlerversion ${BUNDLER_VERSION}" \
	--define "__rubygemsversion ${RUBYGEMS_VERSION}" \
	--resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock \
        --define "__version ${VERSION}" \
        --define "__release ${RELEASE}" \
	--define "__rubyversion ${RUBY_VERSION}" \
	--define "__bundlerversion ${BUNDLER_VERSION}" \
	--define "__rubygemsversion ${RUBYGEMS_VERSION}" \
	--resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

ret=$?

# cleaning
rm -rf SOURCES

if [ $ret -ne 0 ]; then
        echo "Error in mock stage ... exiting"
        exit 1
fi

# sync to cache and repo
f_rsync_iso pkgs/${PACKNAME}${LIBVER}-${VERSION}-${RELEASE}.el7.rb.x86_64.rpm
f_rsync_repo pkgs/${PACKNAME}*.rpm  
rm -rf pkgs
#
# Update sdk7 repo
f_rupdaterepo


#!/bin/bash

VERSION=1.0
PACKNAME=rb_monitor

# First we need to download source
mkdir SOURCES
wget https://github.com/redBorder/rb_monitor/archive/80c18729508174ea0776a0ddc5eb76ce544a8967/1.0.tar.gz -O SOURCES/${PACKNAME}-1.0.tar.gz

# rebuild tarball
cd SOURCES
tar xzf ${PACKNAME}-1.0.tar.gz
mv ${PACKNAME}-80c18729508174ea0776a0ddc5eb76ce544a8967 ${PACKNAME}-1.0
tar czf ${PACKNAME}-1.0.tar.gz rb_monitor-1.0
rm -rf ${PACKNAME}-1.0

# Now it is time to create the source rpm
#/usr/bin/mock -r default --define "__version ${VERSION}" --define "__release 1" --resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
#/usr/bin/mock -r default --define "__version ${VERSION}" --define "__release 1" --resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

# cleaning
#rm -rf SOURCES


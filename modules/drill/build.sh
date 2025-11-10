#!/bin/bash

source build_common.sh

VERSION=${VERSION:="1.20.0"}
RELEASE=${RELEASE:="1"}
PACKNAME=${PACKNAME:="apache-drill"}

CACHEDIR=${CACHEDIR:="/isos/ng/latest/rhel/9/x86_64"}
REPODIR=${REPODIR:="/repos/ng/latest/rhel/9/x86_64"}
REPODIR_SRPMS=${REPODIR_SRPMS:="/repos/ng/latest/rhel/9/SRPMS"}

list_of_packages="${REPODIR_SRPMS}/${PACKNAME}-${VERSION}-${RELEASE}.el9.src.rpm \
                  ${REPODIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm \
                  ${CACHEDIR}/${PACKNAME}-${VERSION}-${RELEASE}.el9.noarch.rpm"

# Check if the package already exists
if [ "x${1:-}" != "xforce" ]; then
    f_check "${list_of_packages}"
    if [ $? -eq 0 ]; then
        echo "Packages already exist. Use '$0 force' to rebuild."
        exit 0
    fi
fi

# Clean previous build artifacts
rm -rf BUILD RPMS SOURCES SPECS SRPMS pkgs

mkdir -p {BUILD,RPMS,SOURCES,SPECS,SRPMS}

echo "Downloading Apache Drill ${VERSION} (Last available version compatible with Java 8)..."

URL="https://archive.apache.org/dist/drill/drill-${VERSION}/apache-drill-${VERSION}.tar.gz"

echo "Downloading from: $URL"
if wget --timeout=60 --tries=3 --waitretry=10 --progress=bar:force -O SOURCES/${PACKNAME}-${VERSION}.tar.gz "$URL"; then
    echo "Download successful!"
else
    echo "Download failed!"
    exit 1
fi

if [ ! -s SOURCES/${PACKNAME}-${VERSION}.tar.gz ]; then
    echo "Error: Downloaded file is empty or missing"
    exit 1
fi


echo "Extracting source package to verify..."
mkdir -p pkgs
if tar -tzf SOURCES/${PACKNAME}-${VERSION}.tar.gz >/dev/null 2>&1; then
    echo "Tarball is valid"
    tar -xzf SOURCES/${PACKNAME}-${VERSION}.tar.gz -C pkgs --strip-components=1
else
    echo "Error: Tarball is corrupt or invalid"
    exit 1
fi

echo "Setting up Java 8 environment..."
export JAVA_HOME="/usr/lib/jvm/java-1.8.0"
export PATH="$JAVA_HOME/bin:$PATH"
echo "Using Java 8 from: $JAVA_HOME"

echo "Verifying Java version for build..."
JAVA_BUILD_VERSION=$(java -version 2>&1 | head -n 1)
echo "Build will use: $JAVA_BUILD_VERSION"

echo "Building RPM packages with Java 8..."
rpmbuild -ba \
    --define "_topdir $(pwd)" \
    --define "_version ${VERSION}" \
    --define "_release ${RELEASE}" \
    SPECS/apache-drill.spec

if [ $? -eq 0 ]; then
    echo "RPM build successful!"
        MAIN_RPM=$(ls RPMS/noarch/${PACKNAME}-${VERSION}-${RELEASE}*.rpm 2>/dev/null | head -1)
    SOURCE_RPM=$(ls SRPMS/${PACKNAME}-${VERSION}-${RELEASE}*.src.rpm 2>/dev/null | head -1)
    
    if [ -n "$MAIN_RPM" ] && [ -n "$SOURCE_RPM" ]; then
        echo "Built packages:"
        echo "  - $MAIN_RPM"
        echo "  - $SOURCE_RPM"
        
        echo "Verifying Java dependencies in RPM..."
        rpm -qp --requires "$MAIN_RPM" | grep -i java
        
        echo "Syncing packages to repositories..."
        f_rsync_repo "$MAIN_RPM"
        f_rsync_repo_SRPMS "$SOURCE_RPM"
        f_rsync_iso "$MAIN_RPM"
        
        echo "Apache Drill ${VERSION} (Java 8 compatible) RPM package has been built successfully!"
    else
        echo "Error: Could not find built RPM files"
        exit 1
    fi
else
    echo "RPM build failed!"
    exit 1
fi

rm -rf BUILD pkgs
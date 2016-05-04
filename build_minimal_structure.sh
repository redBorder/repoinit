#!/bin/bash

f_usage() {
    echo "$0 [-h] -d directory -f isofile"
    echo "  -f isofile   : Path to ISO file containing a CentOS 7 minimal image (mandatory)"
    echo "  -d directory : Create all sdk structure under this directory (mandatory)"
    echo "  -h           : Print this help"
}

opt_file=""
opt_directory=""
cache_dir="/tmp/sdk7_cache"
ret=0

while getopts "hf:d:" opt; do
    case $opt in
        h)
            f_usage
            exit 1
            ;;
        f)
            opt_file=${OPTARG}
            ;;
        d)
            opt_directory=${OPTARG}
            ;;
        \?)
            f_usage
            exit 1
            ;;
        :)
            f_usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

# Check some opts
if [ "x${opt_file}" == "x" -o "x${opt_directory}" == "x" ]; then
    echo "Need to set some parameters"
    f_usage
    exit 1
fi
if [ -f ${opt_file} ]; then
    file -b --mime-type ${opt_file} | grep -q "application/x-iso9660-image"
    if [ $? -ne 0 ]; then
        echo "The file ${opt_file} is not an ISO image"
        f_usage
        exit 1
    fi
else
    echo "The file ${opt_file} does not exist"
    f_usage
    exit 1
fi

# Create directories
mkdir -p ${opt_directory}/isolinux/{images,ks,LiveOS,Packages}
mkdir -p ${cache_dir}/{minimal_rpms,extra_rpms,custom_rpms}

# Create mount point and mount iso file
mount_point=$(mktemp -d /tmp/XXXXX)
sudo mount -o loop ${opt_file} ${mount_point} &>/dev/null

# Cache packages for minimal_rpms
for rpmfile in $(find ${mount_point}/Packages/ -name *.rpm -exec basename {} \;); do
    if [ -f ${cache_dir}/minimal_rpms/${rpmfile} ]; then
        file --mime-type -b ${cache_dir}/minimal_rpms/${rpmfile} | grep -q "application/x-rpm"
        if [ $? -eq 0 ]; then
            continue
        fi
    fi
    cp ${mount_point}/Packages/${rpmfile} ${cache_dir}/minimal_rpms/
done

# Cache packages for extra_rpms
while read rpmlink; do
    rpmfile=$(basename ${rpmlink})
    if [ -f ${cache_dir}/extra_rpms/${rpmfile} ]; then
        file --mime-type -b ${cache_dir}/extra_rpms/${rpmfile} | grep -q "application/x-rpm"
        if [ $? -eq 0 ]; then
            continue
        fi
    fi
    wget -q ${rpmlink} -O ${cache_dir}/extra_rpms/${rpmfile}
done < list_of_rpms_for_download.txt

# Copy needed files
rsync -a ${mount_point}/isolinux/* ${opt_directory}/isolinux/
rsync -a ${mount_point}/images/* ${opt_directory}/isolinux/images/
rsync -a ${mount_point}/LiveOS/* ${opt_directory}/isolinux/LiveOS/
cp ${mount_point}/.discinfo ${opt_directory}/isolinux/
cp ${mount_point}/repodata/*-c7-x86_64-comps.xml.gz ${opt_directory}/comps.xml.gz
gunzip ${opt_directory}/comps.xml.gz
cp isolinux-base.cfg ${opt_directory}/isolinux/isolinux.cfg
cp ks-base.cfg ${opt_directory}/isolinux/ks/ks.cfg
cp splash.png ${opt_directory}/isolinux/

# Sync packages from ISO to custom ISO
rsync -a ${cache_dir}/minimal_rpms/. ${opt_directory}/isolinux/Packages/
rsync -a ${cache_dir}/extra_rpms/. ${opt_directory}/isolinux/Packages/
rsync -a ${cache_dir}/custom_rpms/. ${opt_directory}/isolinux/Packages/

# Umount ISO and remove temporary directory
sudo umount ${mount_point}
rmdir ${mount_point}

# Test rpm depencies
rpmdb_dir=$(mktemp -d /tmp/XXXXX)
pushd ${opt_directory}/isolinux/Packages/ &>/dev/null
rpm --initdb --dbpath ${rpmdb_dir} &>/dev/null
rpm --test --dbpath ${rpmdb_dir} -Uvh *.rpm &>/dev/null
if [ $? -ne 0 ]; then
    echo "Error in rpm dependencies. Please, check the output:"
    rpm --test --dbpath ${rpmdb_dir} -Uvh *.rpm
    ret=1
else
    # deps are ok, creating repo
    pushd ${opt_directory}/isolinux
    createrepo -g ${opt_directory}/comps.xml .
    popd &>/dev/null
fi
popd &>/dev/null
rm -rf ${rpmdb_dir}

exit $ret

## vim:ts=4:sw=4:expandtab:ai:nowrap:formatoptions=croqln:

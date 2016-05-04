#!/bin/bash

f_usage() {
    echo "$0 [-h] -f isofile -d directory"
    echo "  -f isofile   : Path to ISO file containing a CentOS 7 minimal image (mandatory)"
    echo "  -d directory : Create all sdk structure under this directory (mandatory)"
    echo "  -h           : Print this help"
}

opt_file=""
opt_directory=""

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
mkdir -p ${opt_directory}/{minimal_rpms,extra_rpms,custom_rpms}

# Create mount point and mount iso file
mount_point=$(mktemp -d /tmp/XXXXX)
sudo mount -o loop ${opt_file} ${mount_point}

# Copy needed files
rsync -a ${mount_point}/isolinux/* ${opt_directory}/isolinux/
rsync -a ${mount_point}/images/* ${opt_directory}/isolinux/images/
rsync -a ${mount_point}/LiveOS/* ${opt_directory}/isolinux/LiveOS/
cp ${mount_point}/.discinfo ${opt_directory}/isolinux/
cp ${mount_point}/repodata/*-c7-x86_64-comps.xml.gz ${opt_directory}/comps.xml.gz
gunzip ${opt_directory}/comps.xml.gz
rsync -a ${mount_point}/Packages/* ${opt_directory}/minimal_rpms/
cp ks-base.cfg ${opt_directory}/isolinux/ks/ks.cfg
cp splash.png ${opt_directory}/isolinux/

# download some needed packages
wget -q https://dl.fedoraproject.org/pub/epel/7/x86_64/a/atop-2.1-1.el7.x86_64.rpm -O ${opt_directory}/custom_rpms/atop-2.1-1.el7.x86_64.rpm
wget -q http://mirror.centos.org/centos-7/7/os/x86_64/Packages/wget-1.14-10.el7_0.1.x86_64.rpm -O ${opt_directory}/extra_rpms/wget-1.14-10.el7_0.1.x86_64.rpm

# Sync packages from ISO to custom ISO
#rsync -a ${opt_directory}/minimal_rpms/*.rpm ${opt_directory}/isolinux/Packages/
#rsync -a ${opt_directory}/extra_rpms/*.rpm ${opt_directory}/isolinux/Packages/
#rsync -a ${opt_directory}/custom_rpms/*.rpm ${opt_directory}/isolinux/Packages/


#pushd ${opt_directory} &>/dev/null

#popd &>/dev/null

sudo umount ${mount_point}
rmdir ${mount_point}

## vim:ts=4:sw=4:expandtab:ai:nowrap:formatoptions=croqln:

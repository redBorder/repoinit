f_usage() {
    echo "$0 [-h] -i isofile -o isofile -d directory"
    echo "  -i isofile   : Path to ISO file containing a CentOS 7 minimal image (mandatory)"
    echo "  -o isofile   : Path to ISO file to be created (mandatory)"
    echo "  -h           : Print this help"
    echo "This script must be executed in the SDK7 project directory"
}

if [ ! -e .sdk7_project ]; then
    echo "You are not in the SDK7 project directory"
    f_usage
    exit 1
fi

opt_infile=""
opt_outfile=""
opt_directory=""

while getopts "hi:o:d:" opt; do
    case $opt in
        h)
            f_usage
            exit 1
            ;;
        i)
            opt_infile=${OPTARG}
            ;;
        o)
            opt_outfile=${OPTARG}
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
if [ "x${opt_infile}" == "x" -o "x${opt_outfile}" == "x" ]; then
    echo "Need to set some parameters"
    f_usage
    exit 1
fi

opt_directory=$(mktemp -d /tmp/XXXXX)
./build_minimal_structure.sh -f ${opt_infile} -d ${opt_directory}


dirtmp=$(mktemp -d /tmp/XXXXX)
rsync -a ${opt_directory}/isolinux ${dirtmp}
cp isolinux-base.cfg ${dirtmp}/isolinux/isolinux.cfg
cp splash.png ${dirtmp}/isolinux/splash.png
cp ks-base.cfg ${dirtmp}/isolinux/ks/ks.cfg

pushd ${dirtmp}/isolinux &>/dev/null
for ksfile in $(ls ks*.cfg 2>/dev/null); do
    echo ${ksfile} | cpio -c -o >> ../initrd.img 
done
popd &>/dev/null

# Sync packages from ISO to custom ISO
rsync -a ${opt_directory}/minimal_rpms/*.rpm ${dirtmp}/isolinux/Packages/
rsync -a ${opt_directory}/extra_rpms/*.rpm ${dirtmp}/isolinux/Packages/
rsync -a ${opt_directory}/custom_rpms/*.rpm ${dirtmp}/isolinux/Packages/

pushd ${dirtmp} &>/dev/null
mkisofs -o ${opt_file} -b isolinux.bin -c boot.cat -no-emul-boot -V 'CentOS 7 x86_64' -boot-load-size 4 -boot-info-table -R -J -v -T isolinux/
popd &>/dev/null

#rm -rf ${dirtmp}



## vim:ts=4:sw=4:expandtab:ai:nowrap:formatoptions=croqln:

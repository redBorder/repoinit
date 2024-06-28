#!/bin/bash

declare -A modules
program=$0
opt_module=""
opt_dir="./modules"
cache_dir="/tmp/rbrepo_cache"

f_usage() {
    echo "$0 [-h] [-p /path/to/modules] -m module"
    echo "  -m module   : name of module to build (mandatory)"
    echo "  -p path     : Path to directory containing the modules (optional)"
    echo "  -h          : Print this help"
}

f_build() {
    local module=$1
    local ret=0

    # check if this module has been built
    if [ ${modules[$module]} -eq 0 ]; then
        # need to build the module
        # check for module dependencies and build them first
        if [ -f ${opt_dir}/$module/modules.dep ]; then
            for moduledep in $(cat ${opt_dir}/$module/modules.dep); do
                # check if the module has been built
                if [ ${modules[$moduledep]} -eq 1 ]; then
                    continue
                else
                    f_build $moduledep
                    if [ $? -ne 0 ]; then
                        echo "Something was wrong ... exiting"
                        ret=1
                    else
                        # echo 'module built successfuly'
                        modules[${moduledep}]=1
                    fi
                fi
            done
        fi
        if [ $ret -eq 0 ]; then
            # echo 'Building the module'
            if [ -x ${opt_dir}/$module/build.sh ]; then
                pushd ${opt_dir}/$module &>/dev/null
                echo "Building module: $module"
                ./build.sh
                if [ $? -ne 0 ]; then
                    echo "Something was wrong ... exiting"
                    ret=1
                fi
                modules[$module]=1
                popd &>/dev/null
            else
                echo "Error: no script to build the module ${module}"
                ret=1
            fi
        fi
    fi

    return $ret
}

while getopts "hm:p:" opt; do
    case $opt in
        h)
            f_usage
            exit 0
            ;;
        m)
            opt_module=${OPTARG}
            ;;
        p)
            opt_dir=${OPTARG}
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

if [ "x${opt_module}" == "x" ]; then
    echo "Error: it is mandatory to indicate module"
    f_usage
    exit 1
fi

if [ ! -d ${opt_dir} ]; then
    echo "Error: ${opt_dir} is not a directory"
    f_usage
    exit 1
fi

pushd ${opt_dir} &>/dev/null
f_empty_dir=1
for module in $(ls -d * 2>/dev/null); do
    f_empty_dir=0
    modules[$module]=0
done
popd &>/dev/null

if [ $f_empty_dir -eq 1 ]; then
    echo "Error: there is no module in path ${opt_dir}"
    f_usage
    exit 1
fi

if [ "${opt_module}" == "all" ]; then
    # need to build all modules in directory
    for module in ${!modules[@]}; do
        # check if the module has been built
        if [ ${modules[$module]} -eq 1 ]; then
            # has been built
            continue
        else
            f_build $module
            if [ $? -ne 0 ]; then
                echo "Something was wrong ... exiting"
                exit 1
            fi
        fi
    done
else
    # need to build only one module
    f_build ${opt_module}
    if [ $? -ne 0 ]; then
        echo "Something was wrong ... exiting"
        exit 1
    fi
fi

## vim:ts=4:sw=4:expandtab:ai:nowrap:formatoptions=croqln:

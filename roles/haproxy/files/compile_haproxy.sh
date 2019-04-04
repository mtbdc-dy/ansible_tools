#!/bin/bash -
#===============================================================================
#
#          FILE: compile_haproxy.sh
#
#         USAGE: ./compile_haproxy.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/26 16时58分43秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit
set -o pipefail

if [ $UID -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

readonly COMPILE_HAPROXY=/tmp/compile_haproxy.info
echo "" > ${COMPILE_HAPROXY}

# 判断 如下的环境变量是否都已存在
readonly ENVIRONMENT_VARIABLES=(HAPROXY_SOURCE_VERSION HAPROXY_INSTALL_DIR TARGET_LINUX_KERNEL_VERSION ANSIBLE_ARCHITECTURE)
for variable in ${ENVIRONMENT_VARIABLES[*]}
do
    # 需要用到 shell 高级编程的 "变量间接引用" 技巧
    eval temp=\$${variable}
    if [ "${temp}" == "" ]
    then
        echo -e "\$${variable} is NULL, please setup!"
        exit 1
    fi
done

[ ! -d ${HAPROXY_INSTALL_DIR} ] && mkdir -p ${HAPROXY_INSTALL_DIR}

if [ -f ${HAPROXY_SOURCE_VERSION} ]
then
    base_dir=$(dirname ${HAPROXY_SOURCE_VERSION})
    cd ${base_dir}

    unarchive_dir=$(basename ${HAPROXY_SOURCE_VERSION} ".tar.gz")
    tar -zxf $(basename ${HAPROXY_SOURCE_VERSION}) -C ${base_dir} > /dev/null
    if [ $? -eq 0 -a -d ${unarchive_dir} ]
    then
        cd ${unarchive_dir}
        make TARGET=${TARGET_LINUX_KERNEL_VERSION} ARCH=${ANSIBLE_ARCHITECTURE} USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 PREFIX=${HAPROXY_INSTALL_DIR} > ${COMPILE_HAPROXY} 2>&1
        [ $? -ne 0 ] && exit 1

        make install PREFIX=${HAPROXY_INSTALL_DIR} > ${COMPILE_HAPROXY} 2>&1
        [ $? -ne 0 ] && exit 1

        cd ../
        rm -rf ${unarchive_dir}
    else
        echo -e "unarchive ${HAPROXY_SOURCE_VERSION} failed!"
        exit 1
    fi
else
    echo -e "${HAPROXY_SOURCE_VERSION} is not exist!"
    exit 1
fi

exit 0
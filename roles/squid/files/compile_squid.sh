#!/bin/bash -
#===============================================================================
#
#          FILE: compile_squid.sh
#
#         USAGE: ./compile_squid.sh
#
#   DESCRIPTION: 
#           (1) 该脚本只负责编译过程
#           (2) 创建安装目录、运行用户、缓存设置 已由 task 完成
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/07 20时21分24秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit
set -o pipefail

if [ $UID -ne 0 ]
then
    echo -e "You should switch to root"
    exit 1
fi

declare -ra ENVIRONMENTS_VARIABLES=(SQUID_SOURCE_CODE SQUID_INSTALL_DIR)
for variable in ${ENVIRONMENTS_VARIABLES[*]}
do
    eval temp=\$${variable}
    if [ "${temp}" == "" ]
    then
        echo -e "${temp} is not setup!"
        exit 1
    fi
done

[ ! -d ${SQUID_INSTALL_DIR} ] && mkdir -p ${SQUID_INSTALL_DIR}

# SQUID_SOURCE_CODE 为绝对路径
if [ -f ${SQUID_SOURCE_CODE} ]
then
    base_dir=$(dirname ${SQUID_SOURCE_CODE})
    source_code=$(basename ${SQUID_SOURCE_CODE})
    directory=$(basename ${SQUID_SOURCE_CODE} ".tar.gz")
    
    cd ${base_dir}
    tar -zxvf ${source_code} -C ${base_dir} > /dev/null 2>&1
    if [ $? -eq 0 -a -d ${directory} ]
    then
        cd ${directory}

        ./configure  --prefix=${SQUID_INSTALL_DIR} \
--enable-async-io=100 \
--with-pthreads \
--enable-storeio="aufs,diskd,ufs" \
--enable-removal-policies="heap,lru" \
--enable-icmp \
--enable-delay-pools \
--enable-useragent-log \
--enable-referer-log \
--enable-kill-parent-hack \
--enable-cachemgr-hostname=localhost \
--enable-arp-acl \
--enable-default-err-language=English \
--enable-err-languages="Simplify_Chinese English" \
--disable-poll \
--disable-wccp \
--disable-wccpv2 \
--disable-ident-lookups \
--disable-internal-dns \
--enable-basic-auth-helpers="NCSA" \
--enable-stacktrace \
--with-large-files \
--disable-mempools \
--with-filedescriptors=64000 \
--enable-ssl \
--enable-x-accelerator-vary \
--disable-snmp \
--with-aio \
--enable-linux-netfilter \
--enable-linux-tproxy > /dev/null

        [ $? -eq 0 ] || exit 1

        make > /dev/null
        [ $? -eq 0 ] || exit 1

        make install > /dev/null
        [ $? -eq 0 ] || exit 1

        cd ../
        rm -rf ${directory}       

    else
        echo -e "unarchive ${SQUID_SOURCE_CODE} failed!"
        exit 1
    fi
else
    echo -e "${SQUID_SOURCE_CODE} is not exist!"
    exit 1
fi

exit 0
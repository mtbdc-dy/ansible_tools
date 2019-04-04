#!/bin/bash -
#===============================================================================
#
#          FILE: compile_zabbix.sh
#
#         USAGE: ./compile_zabbix.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/25 22时48分36秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

if [ ${UID} -ne 0 ]
then
	echo -e "You should switch to root"
	exit 1
fi

readonly COMPILE_INFO=/tmp/compile_zabbix.info
echo "" > ${COMPILE_INFO}

# 验证 环境变量 是否有效存在
ENVIRONMENT_VARIABLES=(ZABBIX_INSTALL_DIR ZABBIX_SOURCE_FILE WITH_MYSQL WITH_ICONV)
for variable in ${ENVIRONMENT_VARIABLES[*]}
do
	# shell 高级编程中 的 "变量间接引用"
    eval temp=\$${variable}
    if [ "${temp}" == "" ]
    then
        echo -e "\$${variable} is NULL!"
        exit 1
    fi
done

# 创建 安装目录
[ ! -d ${ZABBIX_INSTALL_DIR} ] && mkdir -p ${ZABBIX_INSTALL_DIR}

if [ -f ${ZABBIX_SOURCE_FILE} ]
then
    base_dir=$(dirname ${ZABBIX_SOURCE_FILE})
    unarchive_dir=$(basename "${ZABBIX_SOURCE_FILE}" ".tar.gz")

    cd ${base_dir}
    tar -zxf $(basename "${ZABBIX_SOURCE_FILE}") -C ${base_dir} > /dev/null
    if [ $? -eq 0 -a -d ${unarchive_dir} ]
    then
        cd ${unarchive_dir}
        ./configure --prefix=${ZABBIX_INSTALL_DIR} \
--enable-server --enable-proxy \
--enable-agent --enable-java  \
--enable-ipv6 --with-mysql=${WITH_MYSQL} \
--with-libxml2 --with-net-snmp \
--with-ssh2 --with-ldap \
--with-libcurl --with-libpcre \
--with-iconv=${WITH_ICONV} > ${COMPILE_INFO} 2>&1

        [ $? -ne 0 ] && exit 1

        make > ${COMPILE_INFO} 2>&1
        [ $? -ne 0 ] && exit 1

        make install > ${COMPILE_INFO} 2>&1
        [ $? -ne 0 ] && exit 1

        cd ../
        rm -rf ${unarchive_dir}
    else
        echo -e "unarchive ${ZABBIX_SOURCE_FILE} failed!"
        exit 1
    fi
else
    echo -e "${ZABBIX_SOURCE_FILE} is not exists!"
    exit 1
fi

exit 0
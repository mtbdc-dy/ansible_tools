#!/bin/bash -  
#========================================================================================================================
#   FILE:  install_zabbix_agentd.sh
#   USAGE: ./install_zabbix_agentd.sh
#   DESCRIPTION: 
#      
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/12/19 12时47分27秒
#   REVISION:  ---
#=========================================================================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${UID} -ne 0 ]
then
	echo -e "You should switch to root"
	exit 1
fi

# 验证 环境变量 是否有效存在
ENVIRONMENT_VARIABLES=(ZABBIX_AGENTD_INSTALL_DIR ZABBIX_SOURCE_CODE)
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

# 验证 安装目录是否存在
[ ! -d ${ZABBIX_AGENTD_INSTALL_DIR} ] && mkdir -p ${ZABBIX_AGENTD_INSTALL_DIR}

if [ -f ${ZABBIX_SOURCE_CODE} ]
then
	base_dir=$(dirname ${ZABBIX_SOURCE_CODE})
	cd ${base_dir}
	
	directory=$(basename ${ZABBIX_SOURCE_CODE} ".tar.gz")
	tar -zxf $(basename ${ZABBIX_SOURCE_CODE}) -C ${base_dir} > /dev/null 2>&1
    if [ -d ${directory} ]
    then
        cd ${directory}
		./configure --prefix=${ZABBIX_AGENTD_INSTALL_DIR} --enable-agent > /dev/null
		[ $? -ne 0 ] && exit 1

		make install > /dev/null
		[ $? -ne 0 ] && exit 1

		cd ../
		rm -rf ${directory}
	else
		exit 1
	fi
else
    echo "${ZABBIX_SOURCE_CODE} is not exists!"
    exit 1
fi

exit 0
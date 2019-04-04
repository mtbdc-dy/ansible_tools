#!/bin/bash -
#===============================================================================
#
#          FILE: compile_mysql.sh
#
#         USAGE: ./compile_mysql.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2018/12/21 14时07分43秒
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

# 验证该脚本运行所需的环境变量是否有效存在,通过 ansible-playbook 注入以下的环境变量
ENVIRONMENT_VARIABLES=(TEMP_STORAGE_DIR MYSQL_HOME_DIR MYSQL_DATA_DIR MYSQL_CONF_DIR MYSQL_RUNNING_DIR MYSQL_LOGS_DIR MYSQL_SOURCE_CODE BOOST_SOURCE_CODE MYSQL_USER MYSQL_GROUP MYSQL_PORT)
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

# 验证安装目录是否存在
INSTALL_DIR=(MYSQL_HOME_DIR MYSQL_CONF_DIR MYSQL_LOGS_DIR MYSQL_RUNNING_DIR)
for dir in ${INSTALL_DIR[*]}
do
    eval temp=\$${dir}
    if [ ! -d ${temp} ]
    then
        echo -e "${temp} directory is not exist!"
        exit 1
    fi
done

if [ -d ${TEMP_STORAGE_DIR} ]
then
    cd ${TEMP_STORAGE_DIR}
    if [ -f ${MYSQL_SOURCE_CODE} -a -f ${BOOST_SOURCE_CODE} ]
    then
        tar -zxvf ${BOOST_SOURCE_CODE} -C ${TEMP_STORAGE_DIR} > /dev/null 2>&1
        boost_directory=$(basename ${BOOST_SOURCE_CODE} ".tar.gz")
        if [ ! -d ${boost_directory} ]
        then 
            echo -e "unarchive ${BOOST_SOURCE_CODE} failed!"
            exit 1
        fi

        tar -zxvf ${MYSQL_SOURCE_CODE} -C ${TEMP_STORAGE_DIR} > /dev/null 2>&1
	    mysql_directory=$(basename ${MYSQL_SOURCE_CODE} ".tar.gz")
	    if [ -d ${mysql_directory} ]
	    then
            cd ${mysql_directory}
            cmake -DCMAKE_INSTALL_PREFIX=${MYSQL_HOME_DIR} \
-DMYSQL_UNIX_ADDR=${MYSQL_RUNNING_DIR}/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_DATADIR=${MYSQL_DATA_DIR} \
-DMYSQL_USER=${MYSQL_USER} \
-DMYSQL_TCP_PORT=${MYSQL_PORT} \
-DENABLE_DOWNLOADS=1 \
-DDOWNLOAD_BOOST=1 \
-DWITH_BOOST=${TEMP_STORAGE_DIR}/${boost_directory} > /dev/null

            if [ $? -ne 0 ]; then exit 1; fi

            make > /dev/null
            if [ $? -ne 0 ]; then exit 1; fi

            make install > /dev/null
            if [ $? -ne 0 ]; then exit 1; fi

            cd ../
            rm -rf ${mysql_directory} ${boost_directory}

        else
            echo -e "unarchive ${MYSQL_SOURCE_CODE} failed!"
            exit 1
        fi
    else
        echo -e "${MYSQL_SOURCE_CODE} or ${BOOST_SOURCE_CODE} are not exists!"
        exit 1
    fi
else
    echo -e "${TEMP_STORAGE_DIR} is not exists!"
    exit 1
fi

exit 0
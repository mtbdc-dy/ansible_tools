#!/bin/bash -
#===============================================================================
#
#          FILE: compile_python.sh
#
#         USAGE: ./compile_python.sh
#
#   DESCRIPTION: 
#           (1) 通过注入 环境变量  的方式向该脚本传递运行参数, 分别为:
#               PYTHON_SOURCE          <=== python 的绝对路径下的源码包
#               PYTHON_INSTALL_DIR     <=== python 的绝对路径下的安装目录
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2018/12/20 09时04分38秒
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

# 测试
#readonly PYTHON_SOURCE="/tmp/Python-2.7.5.tgz"
#readonly PYTHON_INSTALL_DIR="/usr/local/python2.7.5"

readonly COMPILE_LOG="/tmp/compile_python.log"

# 判断 如下的环境变量是否都已存在
readonly ENVIRONMENT_VARIABLES=(PYTHON_SOURCE PYTHON_INSTALL_DIR)
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

if [ -f ${PYTHON_SOURCE} ]
then
    father_dir=$(dirname ${PYTHON_SOURCE})
    unarchive_dir=$(basename ${PYTHON_SOURCE} ".tgz")

    #echo -e ${father_dir}
    #echo -e ${unarchive_dir}
    cd ${father_dir}
    tar -zxvf $(basename ${PYTHON_SOURCE}) -C ${father_dir} > /dev/null 2>&1
    if [ $? -eq 0 -a -d ${unarchive_dir} ]
    then
        cd ${father_dir}/${unarchive_dir}
        ./configure --prefix=${PYTHON_INSTALL_DIR} > ${COMPILE_LOG} 2>&1
        make >> ${COMPILE_LOG} 2>&1
        make install >> ${COMPILE_LOG} 2>&1

        cd ../
        rm -rf ${unarchive_dir}

    else
        echo -e "unarchive ${PYTHON_SOURCE} failed!"
        exit 1
    fi
else
    echo -e "${PYTHON_SOURCE} is not exists!"
    exit 1
fi

exit 0
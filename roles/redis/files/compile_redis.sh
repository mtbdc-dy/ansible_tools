#!/bin/bash -
#===============================================================================
#
#          FILE: compile_redis.sh
#
#         USAGE: ./compile_redis.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/29 09时39分41秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

if [ ${UID} -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

readonly COMPILE_REDIS=/tmp/compile_redis.info
echo "" > ${COMPILE_REDIS}
# 判断源码文件是否存在
if [ ! -f ${REDIS_SOURCE_CODE} ]
then
    echo -e "${REDIS_SOURCE_CODE} is not exist!"
    exit 1
fi

base_dir=$(dirname ${REDIS_SOURCE_CODE})
unarchive_dir=$(basename ${REDIS_SOURCE_CODE} ".tar.gz")

cd ${base_dir}
tar -zxf $(basename ${REDIS_SOURCE_CODE}) -C ${base_dir} > /dev/null
if [ $? -eq 0 -a -d ${unarchive_dir} ]
then
    cd ${unarchive_dir}
    make > ${COMPILE_REDIS} 2>&1
    make test > ${COMPILE_REDIS} 2>&1
    make install > ${COMPILE_REDIS} 2>&1
else
    echo -e "unarchive ${REDIS_SOURCE_CODE} failed"
    exit 1
fi

exit 0
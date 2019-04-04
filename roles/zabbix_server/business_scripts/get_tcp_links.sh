#!/bin/bash -
#===============================================================================
#
#          FILE: get_tcp_numbers.sh
#
#         USAGE: ./get_tcp_numbers.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION:
#       CREATED: 2018/12/12 12时53分30秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

if [ $UID -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

# 声明联合数组存储 TCP 连接状态数值
declare -A TCP_ARRAY
TCP_ARRAY=([CLOSE_WAIT]=0 [ESTABLISHED]=0 [FIN_WAIT2]=0 [TIME_WAIT]=0)

# 存储统计结果路径
readonly STORE_DATA="/lvm_extend_partition/qos/zabbix-3.4/etc/statistical_data"
readonly DATA_RESULT="${STORE_DATA}/result.txt"

if [ ! -d ${STORE_DATA} ]
then
    mkdir -p ${STORE_DATA}
fi

if [ ! -f ${DATA_RESULT} ]
then
    for key in ${!TCP_ARRAY[*]}
    do
        echo "${key}:0" >> ${DATA_RESULT}
    done
fi

for key in ${!TCP_ARRAY[*]}
do
    data=$(netstat -n | awk '/^tcp/ {++S[$NF]} END{for(m in S) print m,S[m]}' | grep -i "${key}" | awk '{print $2}')
    if [ "${data}" != "" ]
    then
        sed -i "s/${key}:[0-9]*/${key}:${data}/" ${DATA_RESULT}
    fi
done
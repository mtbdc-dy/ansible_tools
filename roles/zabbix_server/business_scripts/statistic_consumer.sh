#!/bin/bash -
#========================================================================================================================
#   FILE: statistic_consumer.sh
#   USAGE: ./statistic_consumer.sh
#   DESCRIPTION:
#
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/11/22 08时47分27秒
#   REVISION:  ---
#=========================================================================================================================

set -o nounset                              # Treat unset variables as an error

# 声明关联数组:  key: 统计指标    value: 数据源目录
declare -A INDICATOR_ARRAY
INDICATOR_ARRAY=([tomcatconsumer1]="/lvm_extend_partition/qos/tomcat-consumer1/logs" [tomcatconsumer2]="/lvm_extend_partition/qos/tomcat-consumer2/logs" [tomcatconsumer3]="/lvm_extend_partition/qos/tomcat-consumer3/logs")
# 处理结果存储
readonly RESULT_FILE="/lvm_extend_partition/qos/zabbix-3.4/etc/statistical_data/result_data.txt"

# 统计时长
TIME_SECTION=5

#创建标签文件
if [ ! -f ${RESULT_FILE} ]
then
    for INDICATOR in ${!INDICATOR_ARRAY[*]}
    do
        echo -e "${INDICATOR}:0" >> ${RESULT_FILE}
    done
fi

for INDICATOR in ${!INDICATOR_ARRAY[*]}
do
    if [ ! -d ${INDICATOR_ARRAY[${INDICATOR}]} ]
    then
        continue
    fi

    STATISTICAL_TIME_SECTION=`date -d -${TIME_SECTION}minute +'%Y-%m-%d %H:%M'`
    CDR_TOTAL_VALUE=0

    DATA_SOURCE=${INDICATOR_ARRAY[${INDICATOR}]}/catalina.out
    if [ -f ${DATA_SOURCE} ]
    then
        CDR_TOTAL_VALUE=`sed -n "/${STATISTICAL_TIME_SECTION}/p" ${DATA_SOURCE} | grep "CDR" | wc -l`
        if [ ${CDR_TOTAL_VALUE} -gt 0 ]
        then
            #echo "${DATA_SOURCE} ----> ${INDICATOR}:${CDR_TOTAL_VALUE}"
            sed -i "s/${INDICATOR}:[0-9]*/${INDICATOR}:${CDR_TOTAL_VALUE}/" ${RESULT_FILE}
        fi
    else
        echo -e "${DATA_SOURCE} is not exists"
    fi
done
#!/bin/bash -
#========================================================================================================================
#   FILE: statistic_api.sh
#   USAGE: ./statistic_api.sh
#   DESCRIPTION:
#               (1) 利用 shell 脚本计算出 tomcatAPI 日志中的业务数据，形成 key:value 的 txt 文档
#               (2) 将单台 API 产生的数据 主动上送到 zabbix_server 端，进行汇总
#
#       OPTIONS: ---
#       REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#       ORGANIZATION: Open Source Corporation
#   CREATED: 2018/10/24 12时47分27秒
#   REVISION:  ---
#=========================================================================================================================

set -o nounset                              # Treat unset variables as an error

#省份编码
readonly source_file="/lvm_extend_partition/qos/tomcatapi/logs/catalina.out"
#结果存储路径
readonly store_directory="/lvm_extend_partition/qos/zabbix-3.4/statistic_data/"
#省份编码
readonly province_codes=(ah bj cq fj gd gs gx gz ha hb he hi hl hn jl js jx ln nm nx qh sc sd sh sn sx tj xj xz yn zj)

#统计各省指标(关联数组)
declare -A province_indicators
province_indicators=([T_Total]=0 [T_Fail_Total]=0 [N_Total]=0 [N_Fail_Total]=0 [N_Fail_3002]=0 [N_Fail_3004]=0 [N_Fail_5065]=0 [N_Fail_6128]=0)

#统计总和指标(关联数组)
declare -A sum_indicators
sum_indicators=([T_Total]=0 [T_Fail]=0 [N_Total]=0 [N_Fail]=0 [D_Total]=0 [D_Fail]=0 [D_Interrupt]=0 [Qos_Error]=0 [Runtime_Ms]=0 [Runtime_All]=0 [Timeout]=0)
sum_file="${store_directory}/statistical_file.txt"

#判断存储路径是否存在，如果不存在，报错并退出
if [ ! -d ${store_directory} ]
then
    echo -e "${store_directory} is not exists!"
    exit 1
fi

#统计数据时间段(00:00 ~ 04:59) 5分钟内的数据
startTime=`date -d "-5 minute" +"%Y-%m-%d %H:%M:%S"`
stopTime=`date +"%Y-%m-%d %H:%M:%S"`

#echo -e "StartTime: ${startTime}\tStopTime: ${stopTime}"

#预处理产生的日志数据源文件: 利用sed命令截取当前时间往前5分钟的日志内容
statistical_file="${store_directory}/pre_catalina.out"
[ ! -f ${statistical_file} ] && touch ${statistical_file}

#在sed命令中引用shell的变量的方法:变量需要使用双引号
cat ${source_file} | egrep "^INFO" | sed -n "/$startTime/,/$stopTime/p" > ${statistical_file}
#cat ${source_file} | sed -n "/$startTime/,/$stopTime/p" > ${statistical_file}
if [ $? -eq 0 ]
then
    echo -e "Cutting catalina.out complete!"
else
    echo -e "pre-handle the catalina.out fail!"
    exit 1
fi

#统计各省指标
for hcode in ${province_codes[*]}
do
    statistical_result="${store_directory}/province_data_${hcode}.txt"
    if [ ! -f ${statistical_result} ]
    then
        for key in ${!province_indicators[*]}
        do
            echo "${key}:${province_indicators[$key]}" >> ${statistical_result}
        done
    fi

    #由于各指标的统计语句不同，故分开编写，统计结果
    #注意以下赋值变量要和统计数组中的元素值要对应，不然在替换更改数值的时候会出错
    province_indicators[N_Total]=`cat ${statistical_file} | grep "\-N1-response-${hcode}" | wc -l`
    province_indicators[N_Fail_Total]=`cat ${statistical_file} | grep "\-N1-response-${hcode}" | egrep -v "status:0|status:2001" | wc -l`
    province_indicators[T_Total]=`cat ${statistical_file} | grep "getToken-gT-response-${hcode}" | wc -l`
    province_indicators[T_Fail_Total]=`cat ${statistical_file} | grep "getToken-gT-response-${hcode}" | egrep -v "status:0|status:2001" | wc -l`

    province_indicators[N_Fail_3004]=`cat ${statistical_file} | grep "\-N1-response-${hcode}" | grep "status:3004" | wc -l`
    province_indicators[N_Fail_5065]=`cat ${statistical_file} | grep "\-N1-response-${hcode}" | grep "status:5065" | wc -l`
    province_indicators[N_Fail_6128]=`cat ${statistical_file} | grep "\-N1-response-${hcode}" | grep "status:6128" | wc -l`
    province_indicators[N_Fail_3002]=`cat ${statistical_file} | grep "\-N1-response-${hcode}" | grep "status:3002" | wc -l`

    #echo -e "province_code: ${hcode}"
    for key in ${!province_indicators[*]}
    do
        if [ -n ${province_indicators[$key]} -a ${province_indicators[$key]} -ge 0 ]
        then
#           echo -e "$key:${province_indicators[$key]}"
            sed -i "s/$key:[0-9]*/$key:${province_indicators[$key]}/" ${statistical_result}
        fi
    done
done

#统计T，D，N等指标数据在一段时间内的总和
if [ ! -f ${sum_file} -a ${statistical_file} ]
then
    for key in ${!sum_indicators[*]}
    do
        echo "${key}:${sum_indicators[${key}]}" >> ${sum_file}
    done
fi

#sum_indicators=([T_Total]=0 [T_Fail]=0 [N_Total]=0 [N_Fail]=0 [D_Total]=0 [D_Fail]=0 [D_Interrupt]=0 [Qos_Error]=0 [Runtime_Ms]=0 [Runtime_All]=0 [Timeout]=0)
sum_indicators[T_Total]=`cat ${statistical_file} | grep "getToken-gT-request" | wc -l`
sum_indicators[T_Fail]=`cat ${statistical_file} | grep "getToken-gT-response" | egrep -v "status:0|status:2001" | wc -l`
sum_indicators[N_Total]=`cat ${statistical_file} | grep "\-N1-request" | wc -l`
sum_indicators[N_Fail]=`cat ${statistical_file} | grep "\-N1-response" | egrep -v "status:0|status:2001"| wc -l`
sum_indicators[D_Total]=`cat ${statistical_file} | grep "\-D1-request" | wc -l`
sum_indicators[D_Fail]=`cat ${statistical_file} | grep "\-D1-response" | egrep -v "status:0|status:2001|status:100" |  wc -l`
sum_indicators[D_Interrupt]=`cat ${statistical_file} | grep "\-D1-response" | grep "status:100" | wc -l`
sum_indicators[Qos_Error]=`cat ${statistical_file} | grep "com.hx.qos.common.exception.QosException" | wc -l`
sum_indicators[Runtime_Ms]=`cat ${statistical_file} | awk -F "-runtime:" '{print $2}' | awk -F "ms-{" '{print $1}' | awk '$1> 3000 {print $1}' | wc -l`
sum_indicators[Runtime_All]=`cat ${statistical_file} | grep "\-runtime:" | wc -l`
sum_indicators[Timeout]=`cat ${statistical_file} | grep "\-N1-response" | awk -F "-runtime:" '{print $2}' | awk -F "ms-{" '{print $1}'| awk '$1>5000 {print $1}' | sort -r | wc -l`

#重定向统计结果
for key in ${!sum_indicators[*]}
do
    #echo "$key:${sum_indicators[$key]}"
    if [ -n ${sum_indicators[$key]} -a ${sum_indicators[$key]} -ge 0 ]
    then
        sed -i "s/$key:[0-9]*/$key:${sum_indicators[$key]}/" ${sum_file}
    fi
done
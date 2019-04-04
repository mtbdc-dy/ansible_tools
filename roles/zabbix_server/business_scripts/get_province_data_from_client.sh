#!/bin/bash -
#========================================================================================================================
#       FILE: get_province_data_from_client.sh
#   USAGE: ./get_province_data_from_client.sh
#   DESCRIPTION:
#       说明:  目标机器已经设置了 免密登陆，避免了交互操作
#               (1) 6 台 TomcatAPI 均配置为 主动上送模式，则其 zabbix_get 不能生效，于是采用将其统计文件 scp 传输到本地，
#                       再进行统计汇总
#               (2) 统计计算后，sed 替换原始旧数据
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

readonly remote_user="root_js"
readonly remote_port=22
readonly remote_files="/lvm_extend_partition/qos/zabbix-3.4/statistic_data/*.txt"

#结果存储路径
readonly store_directory="/lvm_extend_partition/qos/monitor_tools/zabbix/statistic_data"
#省份编码
declare -ra province_codes=(ah bj cq fj gd gs gx gz ha hb he hi hl hn jl js jx ln nm nx qh sc sd sh sn sx tj xj xz yn zj)
# TomcatAPI 主机数组
declare -ra api_ips=(10.140.132.3 10.140.132.4 10.140.132.5 10.140.132.6 10.140.132.7 10.140.132.8)

#统计各省指标和(关联数组)
declare -A sum_indicators
sum_indicators=([T_Total]=0 [T_Fail_Total]=0 [N_Total]=0 [N_Fail_Total]=0 [N_Fail_3002]=0 [N_Fail_3004]=0 [N_Fail_5065]=0 [N_Fail_6128]=0)
# T、N 成功率指标 ---> 计算结果是浮点型,保留一位小数
declare -A success_rate=([T_RATE]=0.0 [N_RATE]=0.0)

#判断存储路径是否存在，如果不存在，报错并退出
if [ ! -d ${store_directory} ]
then
    echo -e "${store_directory} is not exists!"
    exit 1
fi

# 下载目标机器文件到本地指定目录
for ip in ${api_ips[*]}
do
		directory="${store_directory}/${ip}"
    if [ ! -d ${directory} ]
    then
        mkdir -p ${directory}
    fi

    # 执行以下 scp 命令时，必须对目标主机设置了免密码登陆
    /usr/local/bin/scp -P ${remote_port} ${remote_user}@${ip}:${remote_files} ${directory}
    if [ $? -ne 0 ]
    then
        exit 1
    fi
done

#统计各省指标
for hcode in ${province_codes[*]}
do
    # 生产统计空文档
    statistical_result="${store_directory}/province_data_${hcode}.txt"
    if [ ! -f ${statistical_result} ]
    then
        for key in ${!sum_indicators[*]}
        do
            echo "${key}:${sum_indicators[$key]}" >> ${statistical_result}
        done
    fi

    indicator_sum=0
    for key in ${!sum_indicators[*]}
    do
        for ip in ${api_ips[*]}
        do
            file="${store_directory}/${ip}/province_data_${hcode}.txt"
            if [ -f ${file} ]
            then
                data=`egrep "^${key}" ${file} | cut -d ':' -f 2`
                if [ $? -eq 0 -a ${data} -gt 0 ] #2> /dev/null
                then
                    indicator_sum=`echo "${indicator_sum} + ${data}" | bc`
                    data=0
                fi
            else
                echo -e "${file} is not exists"
                exit  1
            fi
        done

        sed -i "s/$key:[0-9]*/$key:${indicator_sum}/" ${statistical_result}
        indicator_sum=0
    done

    # 统计 T、N 的成功率
    for rate in ${!success_rate[*]}
    do
        result=$(grep -i "${rate}" ${statistical_result})
        if [ "${result}" == "" ]
        then
            echo "${rate}:${success_rate[${rate}]}" >> ${statistical_result}
        fi
    done

    # 计算
    t_total=$(grep -i "T_Total" ${statistical_result} | cut -d ":" -f 2)
    t_fail_total=$(grep -i "T_Fail_Total" ${statistical_result} | cut -d ":" -f 2)
    if [ "${t_total}" != "" -a ${t_fail_total} != "" -a ${t_total} -gt 0 -a ${t_total} -ge ${t_fail_total} ]
    then
        t_success_total=$(echo "${t_total} - ${t_fail_total}" | bc)
        success=$(echo "scale=2;(${t_success_total} * 100) / ${t_total}" | bc)
        if [ $? -eq 0 ]
        then
            sed -in "s/^T_RATE:\([0-9]\{1,2\}\.[0-9]\{1,2\}\)$/T_RATE:${success}/" ${statistical_result}
        fi
    fi

    n_total=$(grep -i "N_Total" ${statistical_result} | cut -d ":" -f 2)
    n_fail_total=$(grep -i "N_Fail_Total" ${statistical_result} | cut -d ":" -f 2)
    if [ "${n_total}" != "" -a ${n_fail_total} != "" -a ${n_fail_total} -gt 0 -a ${n_total} -ge ${n_fail_total} ]
    then
        n_success_total=$(echo "${n_total} - ${n_fail_total}" | bc)
        success=$(echo "scale=2;(${n_success_total} * 100) / ${n_total}" | bc)
        if [ $? -eq 0 ]
        then
            sed -in "s/^N_RATE:\([0-9]\{1,2\}\.[0-9]\{1,2\}\)$/N_RATE:${success}/" ${statistical_result}
        fi
    fi

    # 删除临时文件 ---> 由于在 使用 sed 替换浮点型数据时，替换原始数据，正则匹配 + -i 参数会生成临时文件
    rm -rf $(dirname ${statistical_result})/*.txtn
done

# 统计 T，D，N 汇总数据
# 声明关联数据，用于存储 汇总数据
declare -A TDN_INDICATOR=([T_Total]=0 [T_Fail]=0 [N_Total]=0 [N_Fail]=0 [D_Total]=0 [D_Fail]=0 [D_Interrupt]=0 [Qos_Error]=0 [Runtime_Ms]=0)

TDN_FILE=${store_directory}/tdn_statistic_sum_file.txt
if [ ! -f ${TDN_FILE} ]
then
    for key in ${!TDN_INDICATOR[*]}
    do
        echo "${key}:${TDN_INDICATOR[$key]}" >> ${TDN_FILE}
    done
fi

for key in ${!TDN_INDICATOR[*]}
do
    sum=0
    for ip in ${api_ips[*]}
    do
        file="${store_directory}/${ip}/statistical_file.txt"
        if [ -f ${file} ]
        then
            data=`egrep "^${key}" ${file} | cut -d ':' -f 2`
            if [ $? -eq 0 -a ${data} -gt 0 ] #2> /dev/null
            then
                sum=`echo "${sum} + ${data}" | bc`
                data=0
            fi
        fi
    done

    sed -i "s/$key:[0-9]*/$key:${sum}/" ${TDN_FILE}
    sum=0
done

echo -e "\nThe running time of this script is $SECONDS's\n\n"
exit 0
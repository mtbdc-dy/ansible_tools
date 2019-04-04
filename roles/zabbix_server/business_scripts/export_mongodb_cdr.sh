#!/bin/bash -
#===============================================================================
#
#          FILE: export_mongodb_cdr.sh
#
#         USAGE: ./export_mongodb_cdr.sh
#
#   DESCRIPTION:
#           (1) 利用 mongodb 自带的 mongoexport 工具，导出所需数据
#           (2) 将导出 csv 文件放在 ftp 服务端的数据目录，供客户端下载
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION:
#       CREATED: 2019/01/02 09时00分35秒
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -o errexit
set -o pipefail

set -o nounset                                  # Treat unset variables as an error

# cdr 话单数据导出后存储目录(放在 ftp 服务器的数据目录下)
readonly STORE_CDR_DIR=/lvm_extend_partition/qos/ftp_data_home
readonly LOG=${STORE_CDR_DIR}/export_mongodb.log
# 从 mysql 数据库导出的 appid 的对应关系表
readonly APPID_RELATION=${STORE_CDR_DIR}/mysql_appid_relation.csv

# mongodb 服务的相关参数设置
readonly MONGODB_HOME=/lvm_extend_partition/qos/mongodb-3.4.6
readonly MONGODB_HOST=xxx.xxx.xxx.xxx
readonly MONGODB_PORT=27017
readonly MONGODB_DATABASE=qostest
readonly MONGODB_USER=qos
# 命令行带有用户认证的密码含有特殊字符，需要转义(勿需使用 "" 引用)
readonly MONGODB_PASS=qos123\!\@\#

# 公司 appid 的可读数组
declare -ra COMPANY_APPID=(tencent bcm JISUSHOUYOU netease 324d4b61-df14-11e7-b817-e0accb778420 76a6068d-26f5-41f1-bc2d-a442def61107 tianyi xunlei fcb385e3-d640-11e7-98f3-e0accb778420 ailibaba)
# 省份编码 code 的只读数组
declare -ra PROVINCE_CODE=(ah bj cq fj gd gs gx gz ha hb he hi hl hn jl js jx ln nm nx qh sc sd sh sn sx tj xj xz yn zj)

# 每日查询导出动作的命名时间戳
SELECT_DATE=$(date -d "-1 day" +"%Y%m%d")
SELECT_MONTH=$(date -d "-1 day" +"%Y%m")
# 保留时限，单位：天
PERSIST_DAY=30

if [ ${UID} -ne 0 ]
then
    echo -e "You should switch to root"
    exit 1
fi

if [ ! -d ${STORE_CDR_DIR} ]
then
    echo -e "${STORE_CDR_DIR} is not exist!"
    exit 1
fi

if [ ! -x ${MONGODB_HOME}/bin/mongoexport ]
then
    echo -e "${MONGODB_HOME}/bin/mongoexport is not execute"
    exit 1
fi

# 开始导库
echo -e "$(date +"%Y-%m-%d %H:%M:%S") ---- starting\n" >> ${LOG}

#  按 天 归类
ARCHIVE_DIR=${STORE_CDR_DIR}/${SELECT_DATE}
[ ! -d ${ARCHIVE_DIR} ] && mkdir -p ${ARCHIVE_DIR}

for appid in ${COMPANY_APPID[*]}
do
# 做多线程运行,可以利用 有名管道控制 后台线程队列数目，避免线程数过大导致的意外情况
{
    for code in ${PROVINCE_CODE[*]}
    do
        # 查询的document 的命名样例 cdr201812sxtencent
        select_collection="cdr${SELECT_MONTH}${code}${appid}"
        select_fields="spid,mdn,sessionId,time,duration,factDuration,resultCode,deleteType,location,locationInfo,time33MDN,ratType,imeiId,imsi,source"
        query="{time:{\$regex:\"^${SELECT_DATE}\"}}"
        output_file="${ARCHIVE_DIR}/${appid}_${code}_${SELECT_DATE}.csv"

        ${MONGODB_HOME}/bin/mongoexport \
--host=${MONGODB_HOST}:${MONGODB_PORT} \
--username=${MONGODB_USER} \
--password=${MONGODB_PASS} \
--db=${MONGODB_DATABASE} \
--collection=${select_collection} \
--type=csv \
--fields=${select_fields} \
--query=${query} --out=${output_file} > /dev/null 2>&1

        if [ $? -eq 0 -a -f ${output_file} ]
        then
            echo -e "export mongodb collection ${select_collection} to ${output_file} success!" >> ${LOG}
        else
            echo -e "export mongodb failed!" >> ${LOG}
            exit 1
        fi

    done
}&

done

wait

sleep 10
# 压缩归档为 .tar.gz 文件
cd ${STORE_CDR_DIR}

if [ -f ${APPID_RELATION} ]
then
    cp -a ${APPID_RELATION} ./
else
    echo -e "${APPID_RELATION} is not exist!" >> ${LOG}
fi

/bin/tar -zcf ${SELECT_DATE}.tar.gz ${SELECT_DATE}
sleep 1
rm -rf ${SELECT_DATE}

# 删除历史文件
find ${STORE_CDR_DIR} -ctime +${PERSIST_DAY} -name "*.tar.gz" -exec rm -rf {} \;

echo -e "\nThe running time of this script is $SECONDS's\n\n" >> ${LOG}
exit 0
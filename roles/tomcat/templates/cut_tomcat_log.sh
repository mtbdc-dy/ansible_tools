#!/bin/bash -
#========================================================================================================================
#   FILE:  Cutting_tomcat_log.sh
#   USAGE: ./Cutting_tomcat_log.sh
#   DESCRIPTION:
#           (1) 操作系统为 CentOS release 6.5 (Final)
#               内核: 2.6.32-431.el6.x86_64
#           (2) 利用 logrotate 进行定量分割 tomcat 的 catalina.out，并备份
#
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/09/19 14时47分27秒
#   REVISION:  ---
#=========================================================================================================================

set -o nounset                              # Treat unset variables as an error
set -o errexit

# tomcat 日志存放目录
readonly LOGS_DIR="{{ tomcat_unarchive_dir }}/logs"
# 持久化保存的期限
readonly PERSIST_DAYS=14

# 在 /etc/logrotate.d/ 目录下创建 tomcat 文件
if [ ! -f /etc/logrotate.d/tomcat ]
then
        cat > /etc/logrotate.d/tomcat << EOF
${LOGS_DIR}/catalina.out {
    daily
    rotate 15
    nocompress
    missingok
    copytruncate
    create 644 {{ tomcat_user }} {{ tomcat_group }}
    size 1024M
    dateext
}
EOF
fi

if [ -d ${LOGS_DIR} ]
then
    /usr/sbin/logrotate /etc/logrotate.conf
    if [ $? -eq 0 ]
    then
        # 以时间戳作为文件尾缀
        suffix_file=$(date +"%Y-%m-%d-%H-%M")
        file="${LOGS_DIR}/catalina.out-`date +"%Y%m%d"`"
        if [ -f ${file} ]
        then
            mv -f ${file} ${LOGS_DIR}/catalina.out.${suffix_file}
        fi
    fi

    # 删除过期日志文件
    find ${LOGS_DIR} -type f -mtime +${PERSIST_DAY} -exec rm -rf {} \;

    # 已经采用了 logrotate 分割日志，所以就不用 log4j 自带的日志分割工具
    rm -rf ${LOGS_DIR}/catalina.`date +"%Y-%m-%d"`.log
    echo "" > ${LOGS_DIR}/localhost.`date +"%Y-%m-%d"`.log
    echo "" > ${LOGS_DIR}/localhost_access_log.`date +"%Y-%m-%d"`.txt
    echo "" > ${LOGS_DIR}/localhost_access_log.`date +"%Y-%m-%d"`.log
else
        echo -e "${LOGS_DIR} is not exists!"
fi

exit 0
#!/bin/bash -
#===============================================================================
#
#         FILE: mysql_full_backup.sh
#
#         USAGE: ./mysql_full_backup.sh
#
#   DESCRIPTION: 
#         (1) 利用 mysqldump + crontab 每周日凌晨进行全备份         
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2018/10/12 14时44分03秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

readonly MYSQL_HOST="127.0.0.1"
readonly MYSQL_PORT=3306
# mysql 安装家目录
readonly MYSQL_HOME_DIR="/lvm_extend_partition/qos/mysql-5.7.24"
readonly MYSQL_SOCKET="${MYSQL_HOME_DIR}/running_info/mysql.sock"
readonly MYSQL_USER="root"
# root 用户密码
readonly MYSQL_PASSWD=""

# mysql 数据备份存储目录
readonly STORE_BACKUP_DIR="/lvm_extend_partition/qos/mysql_backup"
# 全量备份文件名称
readonly MYSQL_FULL_BACKUP_FILE=${STORE_BACKUP_DIR}/all_databases_$(date +"%Y-%m-%d").sql.gz
# 备份操作的记录日志
readonly OPERATE_LOG="${STORE_BACKUP_DIR}/operate_backup.log"
# 持久化文件保存期限,单位: 天
readonly PERSIST_DAYS=30

# 自动交互需要使用 expect 软件，
# 先检测是否安装了(expect 的默认安装路径为: /usr/bin/expect)
if [ ! -f /usr/bin/expect ]
then
    echo -e "\033[31m yum install expect tcl \033[0m"
	exit 1
fi

[ ! -d ${STORE_BACKUP_DIR} ] && mkdir -p ${STORE_BACKUP_DIR}

echo -e "------ Start full backup mysql databases ($(date +"%Y-%m-%d %H:%M:%S")) ------" >> ${OPERATE_LOG}
expect >> ${OPERATE_LOG} << EOF
	spawn ${MYSQL_HOME_DIR}/bin/mysqldump -u ${MYSQL_USER} -p -S ${MYSQL_SOCKET} --opt --routines --events --flush-logs --single-transaction --master-data=2 --default-character-set=utf8 --all-databases | gzip > ${MYSQL_FULL_BACKUP_FILE} 
	expect {
        "Enter password:" { send "${MYSQL_PASSWD}\n"}
	}
	expect eof
EOF

# 删除历史文件
find ${STORE_BACKUP_DIR} -ctime +${PERSIST_DAYS} -name "*.sql.gz" -exec rm -rf {} \;
echo -e "------ Backup time consuming ${SECONDS}'s ------\n\n" >> ${OPERATE_LOG}
exit 0 
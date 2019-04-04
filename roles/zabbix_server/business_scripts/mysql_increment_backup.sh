#!/bin/bash -
#===============================================================================
#
#          FILE: mysql_increment_backup.sh
#
#         USAGE: ./mysql_increment_backup.sh
#
#   DESCRIPTION: 
#           (1) 即每天凌晨备份 二进制日志文件
#           (2) 使用 mysqlbinlog mysql-bin.0000xx | mysql -u用户名 -p密码 数据库名
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/02/12 14时44分27秒
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

# mysql 二进制备份存储目录
readonly STORE_BACKUP_DIR=/lvm_extend_partition/qos/mysql_backup/$(date +"%Y-%m-%d")
# 备份操作的记录日志
readonly OPERATE_LOG="${STORE_BACKUP_DIR}/operate_backup.log"
# 持久化文件保存期限,单位: 天
readonly PERSIST_DAYS=30
# 每次新形成的 二进制文件
readonly BIN_LOG_FILE=${MYSQL_HOME_DIR}/logs/mysql-bin.index

# 自动交互需要使用 expect 软件，
# 先检测是否安装了(expect 的默认安装路径为: /usr/bin/expect)
if [ ! -f /usr/bin/expect ]
then
    echo -e "\033[31m yum install expect tcl \033[0m"
	exit 1
fi

# 手动刷新二进制日志 mysql-bin.00000*文件
expect >> ${OPERATE_LOG} << EOF
	spawn ${MYSQL_HOME_DIR}/bin/mysqladmin -u ${MYSQL_USER} -p -S ${MYSQL_SOCKET} flush-logs
	expect {
        "Enter password:" { send "${MYSQL_PASSWD}\n"}
	}
	expect eof
EOF

[ ! -d ${STORE_BACKUP_DIR} ] && mkdir -p ${STORE_BACKUP_DIR}

echo -e "------ Start backup bin logs ($(date +"%Y-%m-%d %H:%M:%S")) ------" >> ${OPERATE_LOG}
# 二进制日志文件的数目
Counter=$(wc -l ${BIN_LOG_FILE} | awk '{print $1}')
NextNum=0
#这个for循环用于比对$Counter,$NextNum这两个值来确定文件是不是存在或最新的。
for file in $(cat ${BIN_LOG_FILE})
do
    base=$(basename ${file})
    let NextNum++

    if [ ${NextNum} -eq ${Counter} ]
    then
        echo "${base} skip!" >> ${OPERATE_LOG}
    else
        dest=${STORE_BACKUP_DIR}/${base}
        if(test -e ${dest})
        then
            echo "${base} exist!" >> ${OPERATE_LOG}
        else
            cp ${file} ${STORE_BACKUP_DIR}
            echo "${base} copying" >> ${OPERATE_LOG}
        fi
    fi
done

# 删除历史文件
cd ${STORE_BACKUP_DIR}
cd ../
find ./ -ctime +${PERSIST_DAYS} -exec rm -rf {} \;
echo -e "------ Backup time consuming ${SECONDS}'s ------\n\n" >> ${OPERATE_LOG}

exit 0
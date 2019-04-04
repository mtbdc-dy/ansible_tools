#!/bin/bash -  
#========================================================================================================================
#   FILE:  zabbix_partition_maintenance.sh
#   USAGE: ./zabbix_partition_maintenance.sh
#   DESCRIPTION: 
#           利用/usr/bin/expect 实现自动交互操作，实现 zabbix mysql 数据库表的定时(crontab)分区维护
#           
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/10/28 12时47分27秒
#   REVISION:  ---
#=========================================================================================================================

set -o nounset                              # Treat unset variables as an error

# 连接 mysql 数据库的相关参数信息
readonly MYSQL_HOME="/lvm_extend_partition/qos/monitor_tools/mysql"
readonly MYSQL_HOST="127.0.0.1"
readonly MYSQL_USER="zabbix"
readonly MYSQL_PORT=3306
readonly MYSQL_DATABASE="zabbix"
readonly MYSQL_PASSWORD="zabbix"
readonly MYSQL_COMMAND="call partition_maintenance_all('zabbix');"

# 自动交互需要使用 expect 软件，
# 先检测是否安装了(expect 的默认安装路径为: /usr/bin/expect)
if [ ! -f /usr/bin/expect ]
then
	echo -e "expect is not installed"
	echo -e "yum install -y expect tcl"
	exit 0
fi

expect << EOF
	spawn ${MYSQL_HOME}/bin/mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -P ${MYSQL_PORT} -p -D ${MYSQL_DATABASE} -e "${MYSQL_COMMAND}"
	expect {
        "Enter password:" { send "${MYSQL_PASSWORD}\n"}
	}
	expect eof
EOF

exit 0
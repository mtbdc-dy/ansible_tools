#!/bin/bash -  
#========================================================================================================================
#   FILE:  mysql_performance_monitor.sh
#   USAGE: ./mysql_performance_monitor.sh
#   DESCRIPTION: 
#       (1) 利用/usr/bin/expect 实现自动交互操作，实现 zabbix mysql 数据库监控模板项的数据提取
#       (2) 利用 percona-toolkit 工具集 检测 mysql 主从结构的相关指标,得到监控数据
#       (3) 在 master 上执行如下命令 
#            pt-heartbeat -D test -h localhost -P 3306 --user=root --ask-pass --create-table --daemoniz --interval=1 --update
#       命令参数说明:           
#            -D 指定heartbeat表建在哪个库，该库需要时开启复制的库。
#            -h -P指定连接的库IP和port信息，指定的连接信息库里面必须有权限。
#            --user --ask-pass 执行连接的用户名和密码
#            --create-table 指创建heartbeat表，若库里没有则创建。
#            --daemoniz 该任务放在后台，持续执行。
#            --intervael 指定update heartbeat表的频率，默认是1s
#            --update 更新主库的heartbeat表。
#
#            在 master 上创建的表结构为:
#            CREATE TABLE heartbeat (
#             ts                    varchar(26) NOT NULL,
#             server_id             int unsigned NOT NULL PRIMARY KEY,
#             file                  varchar(255) DEFAULT NULL,    -- SHOW MASTER STATUS
#             position              bigint unsigned DEFAULT NULL, -- SHOW MASTER STATUS
#             relay_master_log_file varchar(255) DEFAULT NULL,    -- SHOW SLAVE STATUS
#             exec_master_log_pos   bigint unsigned DEFAULT NULL  -- SHOW SLAVE STATUS
#           );
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

# 用户名
readonly MASTER_MYSQL_USER="zabbix"
# 密码
readonly MASTER_MYSQL_PASSWORD=""
# 主机地址/IP
readonly MASTER_MYSQL_HOST="10.1.163.170"
# 端口
readonly MASTER_MYSQL_PORT=3306
# mysql 的家目录
readonly MASTER_MYSQL_HOME="/lvm_extend_partition/qos/mysql-5.6.40/"
# 用于测试的数据库名称
readonly MASTER_MYSQL_DB="test"
#分析文件存储路径
readonly ANALYSIS_FILE="/lvm_extend_partition/qos/zabbix-3.4/scripts/result.txt"
#延迟阈值, 单位: 秒
readonly DELAY_TIME=120

# mysql slave 的相关配置参数
readonly SLAVE_MYSQL_IP="10.1.163.171"
readonly SLAVE_MYSQL_PORT=3306
readonly SLAVE_MYSQL_USER="zabbix"
readonly SLAVE_MYSQL_PASSWD=""

# 用于记录当前的延迟数值
CURRENT_DELAY=0
# 参数是否正确
if [ $# -ne "1" ]
then 
    echo "arg error!"
    exit 1
fi 

# 自动交互需要使用 expect 软件，
# 先检测是否安装了(expect 的默认安装路径为: /usr/bin/expect)
if [ ! -f /usr/bin/expect ]
then
    echo -e "\033[31m yum install expect tcl \033[0m"
	exit 1
fi

if [ ! -x /usr/bin/pt-heartbeat ]
then
    echo -e "\033[31m yum install https://www.percona.com/redir/downloads/percona-release/redhat/latest/percona-release-0.1-6.noarch.rpm \033[0m"
    echo -e "\033[31m yum install percona-toolkit \033[0m"
    exit 1
fi

# Desc: 获取 mysql 实例的 extended-status 状态值
# args: $1 --> 传入的命令
# return: 命令执行结果 
function get_performance_indicators()
{
	local status=$1
	#Uptime: 3277658  Threads: 16  Questions: 7819500  Slow queries: 1016344  Opens: 431  Flush tables: 4  Open tables: 128  Queries per second avg: 2.385
	expect << EOF
	spawn ${MYSQL_HOME}/bin/mysqladmin -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p $status
	expect {
        "Enter password:" { send "${MYSQL_PASSWORD}\n"}
	}
	expect eof
	
	catch wait result
	exit [lindex \$result 3]
EOF

# 说明: 在 获取 子进程的返回值时，需要给以 \$result 的形式，不然会被解释为 shell 的变量
# 	实际为 expect 的定义变量
}

# Desc: pt-heartbeat 在master中插入一条带有当前时间（MySQL中的now()函数）
# 的记录到心跳表中，然后，该记录会复制到slave中。slave根据当前的系统时间戳（Perl中的time函数）
# 减去heartbeat表中的记录值来判断主从的延迟情况
function get_master_slave_delay()
{
    local hb_status=$(ps -ef | grep pt-heartbeat | grep update | grep daemoniz | wc -l)
    if [ ${hb_status} -eq 0 ]
    then
        err_msg="pt-heartbeat is unavailable!"
        return 1
    fi
​
    # pt-heartbeat -D test --check -h 192.168.244.20 --master-server-id=1 -u monitor -p monitor123
    local delay_time=$(pt-heartbeat -h ${SLAVE_MYSQL_IP} -P ${SLAVE_MYSQL_PORT} -u ${SLAVE_MYSQL_USER} -p ${SLAVE_MYSQL_PASSWD} -D ${MASTER_MYSQL_DB} --check)
    if [ $? -ne 0 ]
    then
        err_msg="slave mysql is unavailable!"
        return 1
    else
        CURRENT_DELAY=delay_time
        return 0 
    fi
}

STATUS_RESULT=`get_performance_indicators status`
get_performance_indicators extended-status > ${ANALYSIS_FILE}

# 获取数据
case $1 in
    Delay_value)
        get_master_slave_delay
        if [ $? -eq 0 ]
        then
            echo ${CURRENT_DELAY}
        else
            echo 86400
        fi
        ;;
    Uptime)
        data=$(echo ${STATUS_RESULT} | cut -d ":" -f 3 | cut -d "T" -f 1)
        echo $data 
        ;; 
	Questions) 
        data=$(echo $STATUS_RESULT | cut -d ":" -f 5 | cut -d "S" -f 1$)
	echo $data 
        ;;
	Slow_queries) 
        data=$(echo $STATUS_RESULT | cut -d ":" -f 6 | cut -d "O" -f 1)
        echo $data 
        ;;
    Com_update) 
        data=$(cat ${ANALYSIS_FILE} | grep -w "Com_update" | cut -d "|" -f 3)
        echo $data 
        ;;
    Com_select) 
        data=$(cat ${ANALYSIS_FILE} | grep -w "Com_select" | cut -d "|" -f 3)
        echo $data 
        ;; 
    Com_rollback) 
        data=$(cat ${ANALYSIS_FILE} | grep -w "Com_rollback" | cut -d "|" -f 3)
		echo $data 
        ;; 
    Com_insert)
        data=$(cat ${ANALYSIS_FILE} | grep -w "Com_insert" | cut -d "|" -f 3)
		echo $data 
        ;; 
    Com_delete)
        data=$(cat ${ANALYSIS_FILE} | grep -w "Com_delete" | cut -d "|" -f 3)
		echo $data 
        ;; 
    Com_commit) 
        data=$(cat ${ANALYSIS_FILE} | grep -w "Com_commit" | cut -d "|" -f 3)
		echo $data 
        ;; 
    Bytes_sent)
        data=$(cat ${ANALYSIS_FILE} | grep -w "Bytes_sent" | cut -d "|" -f 3)
        echo $data 
        ;; 
    Bytes_received) 
        data=$(cat ${ANALYSIS_FILE} | grep -w "Bytes_received" |cut -d"|" -f 3)
		echo $data 
		;; 
    Com_begin)
        data=$(cat ${ANALYSIS_FILE} | grep -w "Com_begin" | cut -d "|" -f 3)
		echo $data 
		;;
	Version)
		data=$(${MYSQL_HOME}/bin/mysql -V)
		echo $data
		;;
	Ping)
		data=$(get_performance_indicators ping | grep -c alive)
		echo $data
		;;
	*) 
        echo "Usage:$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|Com_begin)" 
        ;; 
esac

exit 0
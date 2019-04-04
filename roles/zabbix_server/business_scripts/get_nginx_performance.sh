#!/bin/bash -  
#==================================================================================
#   FILE:  monitor_nginx_performance.sh
#   USAGE: ./monitor_nginx_performance.sh
#   DESCRIPTION: 
#           (1) 操作系统为 CentOS release 6.5 (Final)
# 				内核: 2.6.32-431.el6.x86_64
#			(2) 要求: 
#					编译安装 nginx 的时候，带有:   --with-http_stub_status_module
#					/path/to/nginx -V     ----> 查看编译参数
#					/path/to/nginx/conf/nginx.conf 中 server 域中配置:
#							
#						location /status {
#	    					stub_status		on;
#	    					access_log 		off;
#	    					allow 		127.0.0.1;
#	    					deny 		all;
#						}
#
#			(3) 利用脚本 获取 nginx 的性能数据
#
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/09/19 14时47分27秒
#   REVISION:  ---
#==================================================================================
set -o nounset                              # Treat unset variables as an error

readonly HOST="127.0.0.1"
readonly PORT="80"
readonly RESULT_FILE="/lvm_extend_partition/qos/zabbix-3.4.13/scripts/result.txt"

# 只所以要利用 文本存储 nginx 的统计结果，是因为
# 在访问量大的情况下，其自带的 with-http_stub_status_module 模块得到的 status 会报 404 not found
# 为了避免 zabbix 在 timeout 时间设置内得不到目标值，于是短期内循环访问，直到结果得出
function get_nginx_status()
{
    while true
    do
		# -s 隐藏下载进度,  -o 并重定向结果到文本
    	/usr/bin/curl -s -o ${RESULT_FILE} "http://${HOST}:${PORT}/status"
    	local check=`grep -rwn --color "404\ Not\ Found" ${RESULT_FILE}`
        if [  "${check}" != "" ]
		then
			echo "" > ${RESULT_FILE}
            sleep 2  
        else
			break
		fi
    done       
}

# 检测nginx进程是否存在
function ping()
{
    /sbin/pidof nginx | wc -l
}

# 检测nginx性能
function active()
{
    grep -rwn --color 'Active' ${RESULT_FILE} | awk '{print $NF}'
}

function reading() 
{
    grep -rwn --color 'Reading' ${RESULT_FILE} | awk '{print $2}'
}

function writing() 
{
    grep -rwn --color 'Writing' ${RESULT_FILE} | awk '{print $4}'
}

function waiting() 
{
    grep -rwn --color 'Waiting' ${RESULT_FILE} | awk '{print $6}'
}

function accepts() 
{
    awk NR==3 ${RESULT_FILE} | awk '{print $1}'
}

function handled() 
{
    awk NR==3 ${RESULT_FILE} | awk '{print $2}'
}

function requests() 
{
    awk NR==3 ${RESULT_FILE} | awk '{print $3}'
}

case $1 in
	ping|active|reading|writing|waiting|accepts|handled|requests)
		get_nginx_status
		# 调用相关函数，获取目标数据
		$1
		;;
    *)
		echo "nginx.status[ping|active|reading|writing|waiting|accepts|handled|requests]"
		;;
esac

exit 0
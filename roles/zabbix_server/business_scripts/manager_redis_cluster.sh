#!/bin/bash -  
#===================================================================================================
#   FILE:  manager_redis_cluster.sh
#   USAGE: ./manager_redis_cluster.sh
#   DESCRIPTION: 
#           (1) 操作系统为 CentOS release 6.5 (Final)
# 				内核: 2.6.32-431.el6.x86_64
#			(2) 利用 脚本启停 redis-cluster 集群
#
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/09/19 14时47分27秒
#   REVISION:  ---
#====================================================================================================
set -o nounset                              # Treat unset variables as an error

# redis cluster 家目录
readonly REDIS_CLUSTER_HOME="/lvm_extend_partition/qos/test_environment/redis-cluster"
# redis 可执行家目录
readonly REDIS_BIN="${REDIS_CLUSTER_HOME}/redis-bin"
# 声明 redis 集群节点 联合数组:  key: port  value: ip
declare -A REDIS_CLUSTER_NODES
REDIS_CLUSTER_NODES=([7001]=127.0.0.1 [7002]=127.0.0.1 [7003]=127.0.0.1 [7004]=127.0.0.1 [7005]=127.0.0.1 [7006]=127.0.0.1 [7007]=127.0.0.1 [7008]=127.0.0.1)

function start()
{
	# TODO
	return 0
}

function stop()
{
	#TODO
	return 0
}

function status()
{
	#TODO
	return
}

if [ $# -eq 1 ]
then
	case $1 in
		start)
			for KEY in ${!REDIS_CLUSTER_NODES[*]}
			do
				# 防止重复启动
				LISTEN_PORT=`netstat -tunlp | grep ${KEY} | awk '{print $4}' | cut -d ":" -f 2`
				if [ "${LISTEN_PORT}" == "" ]
				then
					cd ${REDIS_CLUSTER_HOME}/${KEY}
					${REDIS_BIN}/redis-server ./redis-${KEY}.conf 2> /dev/null
					sleep 1
				fi
			done
			;;
		stop)
			PIDS=(`ps aux | grep redis | grep -v grep | awk '{print $2}' | xargs`)
			if [ ${#PIDS[*]} -gt 0 ]
			then
				for PID in ${PIDS[*]}
				do
					kill ${PID}
					sleep 1
				done
			fi
			;;
		*)
			echo -e "Usage: bash $0 start|stop|help"
			;;
	esac
else
	echo -e "Usage: bash $0 start|stop|help"
fi

exit 0
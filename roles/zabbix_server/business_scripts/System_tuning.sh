#!/bin/bash -  
#========================================================================================================================
#   FILE:  System_tuning.sh
#   USAGE: ./System_tuning.sh
#   DESCRIPTION: 
#           (1) 操作系统为 CentOS release 6.5 (Final)
# 				内核: 2.6.32-431.el6.x86_64
# 				
#			(2) 脚本已经过测试。如果在执行过程中提示错误，可能是主机的编码问题，可执行
# 				如下命令进行转换
#				yum install -y dos2unix
#				dos2unix file
#				
#				设置主机的字符集和语言
#				locale -a 
# 				vim /etc/sysconfig/i18n
#				LANG="zh_CN.GBK"
#				SUPPORTED="zh_CN.UTF-8:zh_CN:zh"
#				SYSFONT="latarcyrheb-sun16"
#
#			然后执行命令: source /etc/sysconfig/i18n
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

if [ $UID -ne 0 ]
then
	echo -e "You should switch to root!"
	exit 0
fi

# 对于提示内容的字体背景设置和字体颜色设置为红色
WORD_BACKGROUND_COLOR="\033[31m"
WORD_COLOR="\033[0m"

# (1)调整 用户进程数限制
LIMIT_CONF="/etc/security/limits.conf"
if [ -f ${LIMIT_CONF} ]
then
	mv ${LIMIT_CONF} ${LIMIT_CONF}_backup_`date +"%y%S"`
	echo -e "${WORD_BACKGROUND_COLOR} (1)Backup ${LIMIT_CONF}. ${WORD_COLOR}"
else
	echo -e "${WORD_BACKGROUND_COLOR} (1)Warning: ${LIMIT_CONF} is not exist! ${WORD_COLOR}"
fi

cat > ${LIMIT_CONF} << EOF
# /etc/security/limits.conf
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - an user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,
#                 for maxlogin limit
#
#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open files
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit (KB)
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to values: [-20, 19]
#        - rtprio - max realtime priority
#
#<domain>      <type>  <item>         <value>
#
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#@student        -       maxlogins       4

* 		soft 	noproc 	11000 
* 		hard 	noproc 	11000 
*		soft　　nofile	65535
*　　	hard　　nofile	65535
*      	soft   	core    0
*       hard    core    0
* 		soft 	noproc 32768 
* 		hard 	noproc 32768 
* 		soft 	nofile 65535
* 		hard 	nofile 65535

# End of file
EOF

# (2)修改 文件句柄(立即生效)
PROFILE="/etc/profile"
if [ -f ${PROFILE} ]
then
	echo -e "\n\n" >> ${PROFILE}
	echo -e "ulimit\t-HSn\t65535" >> ${PROFILE}
	
	echo -e "${WORD_BACKGROUND_COLOR} (2)Modify the file handle to 65535 ${WORD_COLOR}"
else
	echo -e "${WORD_BACKGROUND_COLOR} (2)Warning: ${PROFILE} is not exist ${WORD_COLOR}"
fi

# (3)禁用ssh-dns（/etc/ssh/sshd_config）
SSHD_CONFIG="/etc/ssh/sshd_config"
if [ -f ${SSHD_CONFIG} ]
then
	sed -i 's%#UseDNS yes%UseDNS no%' /etc/ssh/sshd_config
	service sshd restart
	echo -e "${WORD_BACKGROUND_COLOR} (3)Close the DNS query of the sshd service ${WORD_COLOR}"
else
	echo -e "${WORD_BACKGROUND_COLOR} (3)Warning: ${SSHD_CONFIG} is not exist ${WORD_COLOR}"
fi

# (4)关闭防火墙
iptables -F
/etc/init.d/iptables save
service iptables stop
echo -e "${WORD_BACKGROUND_COLOR} (4) Shutdown the iptables service ${WORD_COLOR}"

# (5)关闭 selinux
SELINUX="/etc/selinux/config"
if [ -f ${SELINUX} ]
then
	sed -i s#SELINUX=enforcing#SELINUX=disabled#g ${SELINUX}
	setenforce 0
	echo -e "${WORD_BACKGROUND_COLOR} (5) Close the SElinux service ${WORD_COLOR}"
else
	echo -e "${WORD_BACKGROUND_COLOR} (5) Warning: ${SELINUX} is not exist ${WORD_COLOR}"
fi

# (6)配置 yum 源 为 自建仓库地址
YUM_REPO="/etc/yum.repos.d"
if [ -d ${YUM_REPO} ]
then
	if [ ! -f ${YUM_REPO}/http.repo ]
	then
		cat > ${YUM_REPO}/http.repo << EOF
[base]
name=RHEL-$releasever - Base - http
baseurl=http://10.140.20.5/CentOS/6.5/x86_64/
gpgcheck=0
EOF
	fi
	
	if [ -f ${YUM_REPO}/CentOS-Base.repo ] 
	then
		mv ${YUM_REPO}/CentOS-Base.repo ${YUM_REPO}/CentOS-Base.repo.`date +"%y%S"`.backup
	fi
	
	mv ${YUM_REPO}/http.repo ${YUM_REPO}/CentOS-Base.repo
	# 清空缓存并重新生成
	yum clean all
	yum makecache
	# yum upgrade
	echo -e "${WORD_BACKGROUND_COLOR} (5) Adjust the yum source to be local ${WORD_COLOR}"
fi

# (7)调整系统内核参数
SYSCTL_CONF="/etc/sysctl.conf"
if [ -f ${SYSCTL_CONF} ]
then
	mv ${SYSCTL_CONF} ${SYSCTL_CONF}.`date +"%y%S"`.backup
	
	# 加载 bridge 模块，对于 ipv6 的支持
modprobe bridge
modprobe nf_conntrack
# 为避免重复往 /etc/rc.local 文件中重定向数据，先查询并删除
sed -i "/^modprobe\ bridge/d" /etc/rc.local
sed -i "/^modprobe\ nf_conntrack/d" /etc/rc.local

echo "modprobe bridge" >> /etc/rc.local
echo "modprobe nf_conntrack" >> /etc/rc.local

	cat > ${SYSCTL_CONF} << EOF
fs.file-max = 999999
kernel.core_uses_pid = 1
kernel.msgmax = 65536
kernel.msgmnb = 65536
kernel.shmall = 4294967296
kernel.shmmax = 68719476736
kernel.sysrq = 0
net.bridge.bridge-nf-call-arptables = 0
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.core.netdev_max_backlog = 2000
net.core.netdev_max_backlog = 262144
net.core.optmem_max = 81920
net.core.rmem_default = 256960
net.core.rmem_max = 513920	
net.core.somaxconn = 262114
net.core.somaxconn = 262144
net.core.wmem_default = 256960
net.core.wmem_max = 513920
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.rp_filter = 1
#net.ipv4.ip_conntrack_max = 20480
net.ipv4.ip_forward = 0
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_fack = 1
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_mem = 131072  262144  524288
net.ipv4.tcp_rmem = 8760  256960  4088000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 8760  256960  4088000
net.ipv6.conf.all.disable_ipv6 = 1
net.netfilter.nf_conntrack_max = 20480
EOF

	sysctl -p
	echo -e "${WORD_BACKGROUND_COLOR} (6) Ajust the system kernel parameters ${WORD_COLOR}"
else
	echo -e "${WORD_BACKGROUND_COLOR} (6) Warning: ${SYSCTL_CONF} file not exist ${WORD_COLOR}"
fi

# (7)配置时间服务器
CRON_FILE="/var/spool/cron/root"
DATE_SERVER="10.140.20.17"
if [ -f ${CRON_FILE} ]
then
	# 为 避免重复添加定时任务，先去重
	sed -i "/ntpdate\ ${DATE_SERVER}/d" ${CRON_FILE}
	echo -e "*/5 * * * * /usr/sbin/ntpdate ${DATE_SERVER} && hwclock -w && hwclock --systohc > /dev/null 2>&1" >> ${CRON_FILE}
	echo -e "${WORD_BACKGROUND_COLOR} (7) Setup the ntpdate server ${WORD_COLOR}"
fi

# (8)设置开机自启动
SETUP_SERVICE=(crond rsyslog sshd network)
for service in ${SETUP_SERVICE[*]}
do 
	chkconfig --level 345 --add ${service}
	chkconfig $service on
done
echo -e "${WORD_BACKGROUND_COLOR} (8) Set up boot self start ${WORD_COLOR}"

# (9)针对 MySQL 作出特殊调优
FILESYSTEM="/etc/fstab"
MYSQL_IPS=(10.140.132.13 10.140.132.14)   #需要根据实际情况调整主机 ip 地址
for ip in ${MYSQL_IPS[*]}
do	
	if [ ! -f ${FILESYSTEM} ]
	then
		continue
	fi
	
	# 可能存在多块网卡，配置了地址
	results=(`ip addr | grep inet | awk '{ print $2; }' | sed 's/\/.*$//' | grep -v "127.0.0.1"`)
	for result in ${results[*]}
	do
		if [ "${result}" != "${ip}" ]
		then
			continue
		fi
		# 因为在 qos 项目下，所有的机器制作的 LVM 均为 /dev/mapper/myvg-mylv
		sed -i "/^\/dev\/mapper\/myvg-mylv/s/^/#&/" ${FILESYSTEM}
		# (1) 关闭数据库挂载目录的 atime 属性
		echo -e '/dev/mapper/myvg-mylv\t/lvm_extend_partition\text4\tnoatime\t0\t0' >> ${FILESYSTEM}
		mount -a
		
		# (2) 普通磁盘可以选择Deadline，SSD我们可以选择使用NOOP或者Deadline
		if [ -f /sys/block/sdb/queue/scheduler ]
		then 
			sed -i "/\/sys\/block\/sdb\/queue\/scheduler/d" /ect/rc.local
			echo "deadline" >> /sys/block/sdb/queue/scheduler
			echo 'echo "deadline" >> /sys/block/sdb/queue/scheduler' >> /etc/rc.local
		fi
		
		if [ -f /sys/block/sdb/queue/scheduler ]
		then
			sed -i "/\/sys\/block\/sdb\/queue\/scheduler\/d" /etc/rc.local
			echo "deadline" >> /sys/block/sdb/queue/scheduler
			echo 'echo "deadline" >> /sys/block/sdb/queue/scheduler' >> /ect/rc.local
		fi
		
		# (3) swappiness是操作系统控制物理内存交换出去的策略
		sed -i "/vm.swappiness\ =\ 0/d" ${SYSCTL_CONF}
		echo "vm.swappiness = 0" >> ${SYSCTL_CONF}
		sysctl -p
		
		echo -e "${WORD_BACKGROUND_COLOR} (9) Tunning the MySQL(${ip}) server ${WORD_COLOR}"
	done
done

# (10)对于 mongoDB 的调优
MONGODB_SERVER=(10.140.132.15 10.140.132.16)
for ip in ${MONGODB_SERVER[*]}
do
	results=(`ip addr | grep inet | awk '{ print $2; }' | sed 's/\/.*$//' | grep -v "127.0.0.1"`)
	for result in ${results[*]}
	do
		if [ "${result}" != "${ip}" ]
		then
			continue
		fi
		
		cat >> /etc/rc.local << EOF
if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]
then
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

if [ -f /sys/kernel/mm/transparent_hugepage/defrag ] 
then
	echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
EOF
		
		if [ -f /sys/block/sdb/queue/scheduler ]
		then
			echo deadline > /sys/block/sdb/queue/scheduler
			sed -i "/\/sys\/block\/sdb\/queue\/scheduler/d" /etc/rc.local
			echo 'echo deadline > /sys/block/sdb/queue/scheduler' >> /etc/rc.local
		fi 
	
		sed -i "/ulimit\ -f\ unlimited/d" ${PROFILE}
		sed -i "/ulimit\ -t\ unlimited/d" ${PROFILE}
		sed -i "/ulimit\ -v\ unlimited/d" ${PROFILE}
		sed -i "/ulimit\ -n\ 65535/d" ${PROFILE}
		sed -i "/ulimit\ -m\ unlimited/d" ${PROFILE}
		sed -i "/ulimit\ -u\ 65535/d" ${PROFILE}
		cat >> ${PROFILE} << EOF
	
ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -n 64535
ulimit -m unlimited
ulimit -u 64535
EOF

		echo -e "${WORD_BACKGROUND_COLOR} (10)Tunning the MongoDB(${ip}) server ${WORD_COLOR}"
	done
done

# (11)Redis 的优化
REDIS_SERVER=(10.140.132.9 10.140.132.10 10.140.132.11 10.140.132.12)
for ip in ${REDIS_SERVER[*]}
do
	results=(`ip addr | grep inet | awk '{ print $2; }' | sed 's/\/.*$//' | grep -v "127.0.0.1"`)
	for result in ${results[*]}
	do
		if [ "${result}" != "${ip}" ]
		then
			continue
		fi
		
		sed -i "/vm.overcommit_memory\ =\ 1/d" ${SYSCTL_CONF}
		echo "vm.overcommit_memory = 1" >> ${SYSCTL_CONF}
		sysctl vm.overcommit_memory=1
		
		if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]
		then
			echo never > /sys/kernel/mm/transparent_hugepage/enabled
			sed -i "/\/sys\/kernel\/mm\/transparent_hugepage\/enabled/d" /etc/rc.local
			echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
		fi
		if [ -f /proc/sys/net/core/somaxconn ]
		then
			echo 511 > /proc/sys/net/core/somaxconn
			sed -i "/\/proc\/sys\/net\/core\/somaxconn/d" /etc/rc.local
			echo 'echo 511 > /proc/sys/net/core/somaxconn' >> /etc/rc.local
		fi
		echo -e "${WORD_BACKGROUND_COLOR} (12) Tunning the Redis(${ip}) server ${WORD_COLOR}"
	done
done

# (12) 修改主机的字符集和语言
LANGUAGE_FILE="/etc/sysconfig/i18n"
if [ -f ${LANGUAGE_FILE} ]
then
	cat > ${LANGUAGE_FILE} << EOF
LANG="zh_CN.GBK"
SUPPORTED="zh_CN.UTF-8:zh_CN:zh"
SYSFONT="latarcyrheb-sun16"
EOF

	echo -e "${WORD_BACKGROUND_COLOR} (12) Switch english to chinese and GBK ${WORD_COLOR}"
fi

echo -e "\n\n"
echo -e "${WORD_BACKGROUND_COLOR}Tunning the Centos6.5 has been worked! ${WORD_COLOR}"
exit 0

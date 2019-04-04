#!/bin/bash -  
#========================================================================================================================
#   FILE:  SetupFreePassword.sh
#   USAGE: ./SetupFreePassword.sh
#   DESCRIPTION: 
#           利用/usr/bin/expect 实现自动交互操作，实现批量免密码登陆
#           
#			问题说明:
#				(1) 对于expect的send的密码中含有的特殊字符，需要使用 "\" 进行转义
# 				(2) 对于需要给expect中传递参数，格式:   set var_name [lindex $argv 0]    以此类推
#           	(3) 当 远程目标主机已经存储了公钥时，这时 expect 就会报错
#						expect: spawn id exp6 not open
#   					while executing
#						"expect eof"
#				目前无解				
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/08/28 12时47分27秒
#   REVISION:  ---
#=========================================================================================================================

set -o nounset                              # Treat unset variables as an error
set -o errexit

# 需要提供 绝对路径的含有免密码交互的主机和密码的 host 文件
if [ $# -ne 1 ]
then
	echo -e "Usage: bash $0 /path/to/hosts"
	exit 0
fi

# 自动交互需要使用 expect 软件，
# 先检测是否安装了(expect 的默认安装路径为: /usr/bin/expect)
if [ ! -f /usr/bin/expect ]
then
	echo -e "expect is not installed"
	echo -e "\033[31m yum install -y expect tcl \033[0m"
	exit 1
fi

HOSTS_FILE=$1
if [ -f ${HOSTS_FILE} ]
then
	CURRENT_USER=`whoami`
	if [ "${CURRENT_USER}" == "root" ]
	then
		SSH_KEY_DIRECTORY="/root/.ssh"
	else
		SSH_KEY_DIRECTORY="/home/${CURRENT_USER}/.ssh"
	fi
	# 使用 rsa 算法创建 公私钥
	if [ ! -f ${SSH_KEY_DIRECTORY}/id_rsa.pub ]
	then
		#ssh-keygen 免交互
		ssh-keygen -t rsa -P "" -f ${SSH_KEY_DIRECTORY}/id_rsa
		if [ $? -eq 0 ]
		then
			echo -e "\033[31m Create id_rsa.pub file succeed! \033[0m"
		else
			echo -e "\033[31m Create id_rsa.pub file failed! \033[0m"
			exit 1	
		fi
	fi
	
	# 用于 ip 地址字符串模式匹配
	MATCH_PATTERN="^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$"
	while read line
	do
		IP=`echo $line | cut -d " " -f1`          # 提取文件中的ip
		USERNAME=`echo $line | cut -d " " -f2`      # 提取文件中的用户名
		PASSWORD=`echo $line | cut -d " " -f3`      # 提取文件中的密码

		# 验证 IP 地址的合法性
		if ! [[ ${IP} =~ ${MATCH_PATTERN} ]]
		then
			echo -e "\033[31m ${IP} is not a legitimate address! \033[0m"
			break
		fi

		expect << EOF
			spawn ssh-copy-id -i ${SSH_KEY_DIRECTORY}/id_rsa.pub ${USERNAME}@${IP}
			expect {
                "yes/no" { send "yes\n";exp_continue}
                "password" { send "${PASSWORD}\n"}
			}
			expect eof
EOF
	done < ${HOSTS_FILE}      # 读取存储ip的文件
else
	echo -e "${HOSTS_FILE} must be absolutely path"
	exit 1
fi

exit 0
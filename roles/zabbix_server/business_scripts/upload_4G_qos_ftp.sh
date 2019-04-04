#!/bin/bash -  
#========================================================================================================================
#   FILE:  upload_4G_qos_ftp.sh
#   USAGE: ./upload_4G_qos_ftp.sh
#   DESCRIPTION: 
#			(1)  通过 FTP 协议上传目标数据
#           (2) 
#           
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: Stalker (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/06/15 09时47分27秒
#   REVISION:  ---
#=========================================================================================================================

set -o nounset                              # Treat unset variables as an error

readonly FTP_IP="xxx.xxx.xxx.xxx"
# ftp 命令端口，默认为 21 
readonly FTP_PORT=21
readonly FTP_USER="xxxxxx"
readonly FTP_PASSWD="xxxxxx"
#FTP 客户端的二进制可执行程序
readonly FTP_BIN="/usr/bin/ftp"
# 上传的数据存储目录
readonly REMOTE_UPLOAD_DIRECTORY="/"
#上传的数据本地目录
readonly OBJECT_DIRECTORY="/home/ftpuser/data"
# 文件日期名称
readonly DATETIME=`date -d "-1 day" +"%Y%m%d"`
# 本地上传文件夹数据名称
readonly LOCAL_UPLOAD_DIRECTORY="4G-QoS-User-${DATETIME}"
# 持久化保存天数
readonly PERSIST_DAYS=14

if [ ! -f ${FTP_BIN} ]
then
    echo -e "ftp is not exist!"
    echo -e "Usage： yum -y install ftp"
    exit 0
fi

if [ -d ${OBJECT_DIRECTORY} ]
then
	cd ${OBJECT_DIRECTORY}
   if [ -d ${LOCAL_UPLOAD_DIRECTORY} ]
   then
		# 创建压缩文件
		cp -a ${LOCAL_UPLOAD_DIRECTORY} ${DATETIME}
		archive_file=${DATETIME}.tar.gz
		tar -zcvf ${archive_file} ${DATETIME} > /dev/null
		if [ $? -eq 0 ]
		then
			${FTP_BIN} -v -n << EOF
            open ${FTP_IP} ${FTP_PORT}
            user ${FTP_USER} ${FTP_PASSWD}
            bin
            cd ${REMOTE_UPLOAD_DIRECTORY}
            put ${archive_file}
            bye
EOF
# 删除创建的压缩文件
			rm -rf ${DATETIME} ${archive_file}	

			# 删除过期数据文件
			find ${OBJECT_DIRECTORY} -mtime +${PERSIST_DAYS} -exec rm -rf {} \; 
		else
			echo -e "Create ${archive_file} faile."
		fi
	else
		echo -e ""
	fi
else
	echo -e "${OBJECT_DIRECTORY} is exist!"
fi

# 为避免程序异常，无法正常退出
exit 0




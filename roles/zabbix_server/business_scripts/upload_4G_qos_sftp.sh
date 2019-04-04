#!/bin/bash -
#================================================
#   FILE:  upload_4G_qos_sftp.sh
#   USAGE: ./upload_4G_qos_sftp.sh
#   DESCRIPTION:
#       (1) 利用 expect 交互操作文件上传 ftp
# 		
# 		注意: 对于 expect 的 send 动作发送 特殊字符，需要转义
# 			\ 	--->  \\\
# 			{   --->  \{
# 			[   --->  \[
# 			$   --->  \\\$
# 			`   --->  \`
# 			"   --->  \\\"
#
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/04/23 12时47分27秒
#   REVISION:  ---
#=================================================
set -o nounset                              # Treat unset variables as an error

# SFTP 的配置信息
readonly DCNIP="xxx.xxx.xxx.xxx"
readonly USER="xxx"
# 特殊字符 需要转义
readonly PASSWORD="xxxx"
readonly PORT=8010

# 本地文件目录
readonly SRCDIR="/lvm_extend_partition/qos/ftp_home/ftpuser"
# 远程上传数据目录
readonly DESTDIR="/sourcedata"
# 上传操作 记录日志文件
readonly LOG_FILE="/lvm_extend_partition/qos/ftp_home/ftpuser/upload_sftp.log"

if [ ! -f /usr/bin/lftp ]
then
    echo -e "You should install lftp"
    echo -e "Help: yum -y install lftp"
    exit 1
fi

if [ ! -f /usr/bin/expect ]
then
        echo -e "You should install expect and tcl"
        echo -e "Help: yum install expect tcl"
        exit 1
fi

echo -e "-------------------------------------------------------" >> ${LOG_FILE}

if [ -d ${SRCDIR} ]
then
    cd ${SRCDIR}
    SRCFILES="4G-QoS-Company-`date -d "-1 day" +"%Y%m%d"`"
    if [ -d ${SRCFILES} ]
    then
        #批量上传文件
        STARTTIME=`date +"%Y-%m-%d %H:%M:%S"`
        echo -e "${STARTTIME} ---- starting upload" >> ${LOG_FILE}

        expect >> ${LOG_FILE} << EOF
            spawn /usr/local/bin/sftp -P ${PORT} ${USER}@${DCNIP}
            expect {
                "*assword:" { send "${PASSWORD}\n" }
            }
            expect {
                "sftp>" { send "cd\ ${DESTDIR}\n" }
            }
            expect {
                "sftp>" { send "lcd\ ${SRCDIR}/${SRCFILES}\n" }
            }
            expect {
                "sftp>" { send "put\ *\n" }
            }
            expect {
                "sftp>" { send "bye\n" }
            }
            expect eof
EOF

        echo -e "\n\n${SRCFILES} has been uploaded!" >> ${LOG_FILE}
    else
        echo -e "${SRCFILES} is not exits" >> ${LOG_FILE}
    fi
else
        echo -e "${SRCDIR} is not exists!" >> ${LOG_FILE}
fi

echo -e "-------------------------------------------------------" >> ${LOG_FILE}
exit 0
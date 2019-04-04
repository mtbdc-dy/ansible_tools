#!/bin/bash -
#===============================================================================
#
#          FILE: compile_vsftp.sh
#
#         USAGE: ./compile_vsftp.sh
#
#   DESCRIPTION: 
#           (1) 该脚本适用于 CentOS / RedHat 系统(经测试)
#           (2) 需要提供 vsftpd 的源码包 ---> 经由 ansible-playbook 传入的环境变量，指定源码包的绝对路径
#           (3) 默认编译安装是不启用 TCP Wrappers ---> 如果需要开启，vim builddefs.h 文件内容为
#               #define VSF_BUILD_TCPWRAPPERS             //允许使用TCP Wrappers（默认是undef）
#               #define VSF_BUILD_PAM                     //允许使用PAM认证
#               #define VSF_BUILD_SSL  
#               
#               说明: 开启 TCP Wrappers --->  yum install -y libcap tcp_wrappers tcp_wrappers_devel
#
#           (4) 编译过程记录日志  /tmp/operate_vsftpd.log
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/03/16 08时01分47秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit

if [ ${UID} -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

# 编译过程记录日志，便于问题定位
readonly COMPILE_VSFTPD_LOG="/tmp/compile_vsftpd.log"

# ansible playbook 剧本传入的 vsftpd 源码版本的环境变量
if [ "${VSFTPD_SOURCE}" != "" ] && [ -f ${VSFTPD_SOURCE} ]
then
    # 源码解压目录
    unarchive_dir=$(dirname ${VSFTPD_SOURCE})
    cd ${unarchive_dir}
    tar -zxvf $(basename ${VSFTPD_SOURCE}) -C ${unarchive_dir} > ${COMPILE_VSFTPD_LOG}
    if [ $? -eq 0 ]
    then
        # 解压后的文件目录名
        unarchived_file_dir=$(basename ${VSFTPD_SOURCE} ".tar.gz")
        if [ -d ${unarchive_dir}/${unarchived_file_dir} ]
        then
            cd ${unarchive_dir}/${unarchived_file_dir}

            # 修改源码文件，关闭 UTF-8 支持
            if [ -f ./opts.c ]
            then
                # if (str_equal_text(&p_sess->ftp_arg_str,"DISABLE UTF8 ON"))
                # 注意: 在 macOS 系统上，就地替换文件，根据提供的扩展名保存源文件备份。如果不提供扩展名，则不备份。建议替换操作时提供文件备份的扩展名，因为如果恰巧磁盘耗尽的话，你将冒着原文件被损坏的风险
                #sed -i "" 's/"UTF8\ ON"/"DISABLE UTF8 ON"/' opts.c

                # 在 Linux 系统
                sed -i 's/"UTF8\ ON"/"DISABLE UTF8 ON"/' opts.c 
            fi

            # ldconfig
            if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] && [ -f ./vsf_findlibs.sh ]
            then
                sed -i 's/lib\//lib64\//g' vsf_findlibs.sh
            fi

            make >> ${COMPILE_VSFTPD_LOG} 2>&1
            make install >> ${COMPILE_VSFTPD_LOG} 2>&1

            # 复制 pam 认证文件
            if [ -f ./RedHat/vsftpd.pam ]
            then
                cp RedHat/vsftpd.pam /etc/pam.d/vsftpd
            fi

            # 删除解压后的源码包文件
            cd ../
            rm -rf ${unarchived_file_dir}
            
            # 将 /etc/xinetd.d/vsftpd 中的 disable 的 no 改为 yes  ====> 使其具有 daemon 的能力
            if [ -f /etc/xinetd.d/vsftpd ]
            then
                sed -i "s/disable                 = no/disable                 = yes/" /etc/xinetd.d/vsftpd
            fi
        fi
    else
        echo -e "unarchive ${VSFTPD_SOURCE} failed!"
        exit 1
    fi
else
    echo -e "\${VSFTPD_SOURCE} is NULL,Please setup it!"
    exit 1
fi

exit 0
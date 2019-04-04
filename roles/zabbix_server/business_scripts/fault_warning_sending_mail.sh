#!/bin/bash -
#===============================================================================
#
#          FILE: fault_warning_sending_mail.sh
#
#         USAGE: ./fault_warning_sending_mail.sh
#
#   DESCRIPTION:
#           (1) 需要配置 扣扣邮箱开启 IMAP/SMTP服务,获取 授权码
#           (2) 利用 openssl 生成 证书
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION:
#       CREATED: 2019/01/29 21时14分41秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit
set -o pipefail

if [ ${UID} -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

# Source networking configuration.
if [ -f /etc/sysconfig/network ]
then
    . /etc/sysconfig/network
fi

# Check that networking is up.
if [ "$NETWORKING" = "no" ]
then
    echo -e "The network is down!"
    exit 1
fi

# 生成 邮件发送的配置信息
function generate_certs()
{
    local frommail='1318895540@qq.com'
    local smtp_host='smtp.qq.com'
    local smtp_auth_user='1318895540@qq.com'
    # 在扣扣邮箱里设置后，会生成一个 授权码
    local smpt_auth_password='uollvjhkusciffdd'
    local certs_dir=/root/.certs
    local mail_conf=/etc/mail.rc

    if [ -f ${mail_conf} ]
    then
        local content=$(cat ${mail_conf} | grep -i 'smtp-auth-user')
        if [ "x$content" != "x"  ]
        then
            echo -e "\033[31m '$mail_conf' 文件已经配置 \033[0m"
            return 0
        fi
    fi

    cat >> $mail_conf <<EOF
set from=${frommail}
set smtp=${smtp_host}
set smtp-auth-user=${smtp_auth_user}
set smtp-auth-password=${smpt_auth_password}
set smtp-auth=login
set smtp-use-starttls
set ssl-verify=ignore
set nss-config-dir=${certs_dir}
EOF

    [ $? -eq 0  ] && echo -e "\033[31m '$mail_conf' 文件配置 \033[0m"

    [ ! -d ${certs_dir} ] && mkdir -p ${certs_dir}
    echo -n | openssl s_client -connect ${smtp_host}:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${certs_dir}/qq.crt
    certutil -A -n "GeoTrust SSL CA" -t "C,," -d ${certs_dir} -i ${certs_dir}/qq.crt
    certutil -A -n "GeoTrust Global CA" -t "C,," -d ${certs_dir} -i ${certs_dir}/qq.crt
    certutil -L -d ${certs_dir}

    [ $? -eq 0  ] && echo -e "\033[31m 生成证书 \033[0m"
    return 0
}

# 生成 认证信息
generate_certs

# 发送邮件
if [ $# -ne 1 ]
then
    echo -e "\033[31m Usage: bash $0 \"message\" \033[0m"
    exit 1
fi

echo $1 | mailx -v -s " title" 1318895540@qq.com
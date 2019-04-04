#!/bin/bash -
#===============================================================================
#
#          FILE: interact_operation.sh
#
#         USAGE: ./interact_operation.sh
#
#   DESCRIPTION: 
#           (1) 当被管理机器过多时,为提高执行效率,采用 "命名管道" 模拟 "多线程 "  同时处理, 可以通过 MULTI_THREADS 变量调整线程池的大小
#           (2) 结合 crontab 的 分钟级(比如 每 5 分钟)进行定时任务
#           (3) 通过 SMTP 发送告警邮件信息,请保证 465 端口的开放      http://caspian.dotconf.net/menu/Software/SendEmail/
#           (4) 通过 nc 远程连接目标机器,判断目标机器的运行状态,如果异常，则发送告警邮件
#           (5) 中控机需要具有 公网 访问能力
#       
#   获取目标机器的统计结果的实现思路:
#           (1) 使用 scp 将 统计脚本 传输到目标机器
#           (2) 集合 中控机的 expect 实现 远程脚本的运行(可能需要切换 超级用户)
#           (3) 统计脚本将统计结果重定向到指定路径下的指定文件，然后中控机再次使用 scp 下载统计结果文件，实现分析和阈值邮件告警
#           
#   调试过程：
#           (1) openssl s_client -showcerts -connect smtp.qq.com:465
#           (2) echo  hello word | mailx -v -s " title" 737735250@qq.com
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/16 10时41分23秒
#      REVISION: v1.0
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o pipefail

# 需要验证的 远程机器数组,假定所有的机器的访问方式都相同，如果不同
# 则可以使用 关联数组
declare -ra SSH_IP=(10.1.163.170)
readonly SSH_PORT=22
readonly SSH_USER=vmuser
readonly SSH_PASSWORD=!Q2w3e4r5t6y
readonly SSH_SUDO_PASSWORD=e\#OOG\#bjL4Rc3JbN

# 设置的超时时间，默认为 10 秒
readonly TIMEOUT=10
# ntpserver 同步时间为 阿里的时间服务器 
readonly CONTROL_NTPSERVER=ntp1.aliyun.com
# 被控机的时间服务器为 ntpserver,默认端口为 123
readonly NTPSERVER=10.1.163.169

# 发送告警的邮箱地址
readonly MAIL_ADDRESS="1318895540@qq.com"
# 扣扣邮箱的官方地址
readonly SMTP_HOST="smtp.qq.com"
# 邮箱登陆私人账号
readonly SMTP_AUTH_USER="${MAIL_ADDRESS}"
# (1) 邮箱需要开启 smtp 接收设置 (2) 填写邮箱服务商提供的 第三方登陆的授权码
readonly SMTP_AUTH_PASSWORD="uollvjhkusciffdd"
# 验证证书存储目录
readonly CERTS_DIR=~/.certs
# 邮箱配置文件
readonly MAIL_CONF=/etc/mail.rc

# 线程池数,如果被管机器过多,可适当调大该值
readonly MULTI_THREADS=10

# 执行 ntpdate 需要 管理员权限
if [ ${UID} -ne 0 ]
then
    echo -e "\033[41;37m You should switch to root! \033[0m" 
    exit 1
fi

# 判断 ntpdate nc 客户端是否已安装
if [ ! -x /usr/sbin/ntpdate  -o ! -x /usr/bin/nc -o ! -x /usr/bin/certutil ]
then
    echo -e "\n \033[41;37m yum install ntpdate nc nss-tools openssl openssl-devel \033[0m \n" 
    exit 1
fi

# 初始化 邮箱客户端
function inital_mail_server()
{
    #. /etc/init.d/functions
    if [ -f ${MAIL_CONF} ]
    then
        local content=$(cat ${MAIL_CONF} | grep 'smtp-auth-user')
        if [ "$content" != ""  ]
        then
            return 0
        fi
    fi

    cat >> ${MAIL_CONF} <<EOF 
set from=${MAIL_ADDRESS}
set smtp=${SMTP_HOST}
set smtp-auth-user=${SMTP_AUTH_USER}
set smtp-auth-password=${SMTP_AUTH_PASSWORD}
set smtp-auth=login
set smtp-use-starttls
set ssl-verify=ignore
set nss-config-dir=${CERTS_DIR}
EOF

    [ $? -eq 0  ] && echo -e "\033[41;37m 配置 ${MAIL_CONF} 文件成功 \033[0m" 
    [ ! -d ${CERTS_DIR} ] && mkdir -p ${CERTS_DIR}

    echo -n | openssl s_client -connect ${SMTP_HOST}:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${CERTS_DIR}/qq.crt
    certutil -A -n "GeoTrust SSL CA" -t "C,," -d ${CERTS_DIR} -i ${CERTS_DIR}/qq.crt
    certutil -A -n "GeoTrust Global CA" -t "C,," -d ${CERTS_DIR} -i ${CERTS_DIR}/qq.crt
    certutil -L -d ${CERTS_DIR}

    [ $? -eq 0  ] && echo -e "生成证书"

    return 0
}

# desc: 当异常情况时，发送邮件告警
# args: $1 --> message
# return: 
function send_mail()
{
    local message=$1
    echo -e "${message}" | /usr/bin/mailx -v -s " title" ${MAIL_ADDRESS} &> /dev/null 

    [ $? -eq 0 ] && return 0 || return 1
}

# desc: 格式化日志
# args: $1 --> , $2 -->
# return:
function print_log()
{
    return 0
}

# 内置重写 action 函数，只输出 返回码(0-255)
function action()
{
    local STRING rc

    STRING=$1
    echo -n "$STRING "
    shift
    "$@" && success $"$STRING" || failure $"$STRING"
    rc=$?
    echo
    return $rc
}

# desc:
#   具体执行任务的脚本
function statistical_shell()
{
    # 为避免 统计脚本内容出现改动而未生效
    [ -f $(pwd)/statistical_shell.sh ] && rm -rf $(pwd)/statistical_shell.sh

    cat >> $(pwd)/statistical_shell.sh << EOF
#!/bin/bash -
#===============================================================================
#
#          FILE: statistical_shell.sh
#
#         USAGE: /bin/bash statistical_shell.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: $(date +"%Y-%m-%d %H:%M:%S")
#      REVISION: v1.0
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o pipefail

# 统计结果重定向文件,由于 ssh 登录到普通用户的家目录，su 切换为 超级用户后的当前路径仍为 普通用户的家目录
readonly STORE_STATISTCAL_FILE=\$(pwd)/statistal_result.txt

# TODO

exit 0
EOF

    return 0
}

# desc:
#   利用 expect 实现 shell 的交互
#   首先以 普通用户 登陆远程主机，然后 su 切换为 超级用户,执行统计脚本
# usage: $(pwd)/interact_expect.exp [ssh_ip] [ssh_port] [ssh_user] [ssh_passwd] [ssh_su_passwd]
function interact_expect()
{
    [ -f $(pwd)/interact_expect.exp ] && return 0 
    # 远程执行的脚本,可通过该脚本,获取需要的信息指标
    cat >> $(pwd)/interact_expect.exp << EOF
#!/usr/bin/expect

set timeout 15

set ssh_ip [lindex \$argv 0]
set ssh_port [lindex \$argv 1]
set ssh_user [lindex \$argv 2]
set ssh_password [lindex \$argv 3]
set ssh_su_password [lindex \$argv 4]
set current_time [exec sh -c {date +%s}]

spawn /usr/bin/scp -o "StrictHostKeyChecking no" -P \${ssh_port} \$(pwd)/statistical_shell.sh \${ssh_user}@\${ssh_ip}:~/
expect {
    "yes/no" { send "yes\r";exp_continue }
    "*assword*" { send "\${ssh_password}\r" }
}
expect {
    "*100*" { send "exit\n" }
}
interact

spawn /usr/bin/ssh -t -o "StrictHostKeyChecking no" -p \${ssh_port} \${ssh_user}@\${ssh_ip}
expect {
    "yes/no" { send "yes\r";exp_continue }
    "*assword*" { send "\${ssh_password}\r" }
}
expect { 
    "*\$*" { send "su root\r" }
}
expect {
    "密码：" { send "\${ssh_su_password}\r" }
}
expect {
    "*#" { send "/bin/bash statistical_shell.sh\r" }
}
expect {
    "*#" { send "exit\n" }  
}
interact

exec sleep 1

spawn /usr/bin/scp -o "StrictHostKeyChecking no" -P \${ssh_port} \${ssh_user}@\${ssh_ip}:~/statistal_result.txt ./
expect {
    "yes/no" { send "yes\r";exp_continue }
    "*assword*" { send "\${ssh_password}\r" }
}
expect {
    "*100*" { send "exit\n" }
}
interact
expect eof

EOF
    return 0
}

# desc:
#   分析统计结果，超过阈值的进行邮件故障告警
function analyst_statistcal_result()
{
    if [ -f $(pwd)/statistal_result.txt ]
    then

    fi

    return 0
}

# 初始化 命名管道
readonly TEMPPIPE=/tmp/$$.fifo
# 判断管道是否存在，如果不存在，则创建
[ -e ${TEMPPIPE} ] || mkfifo ${TEMPPIPE}
# 创建文件描述符，以可读(<)、可写(>) 的方式关联管道文件
exec 3<> ${TEMPPIPE}
# 关联后的文件描述符拥有管道文件的所有特性,可用完删除
rm -rf ${TEMPPIPE}

for ((i=1;i<=${MULTI_THREADS};i++))
do
    # 引用文件描述符，并往管道里塞入操作令牌
    echo >&3
done

inital_mail_server

for ip in ${SSH_IP[*]}
do
    read -u3
    {
        # 以 ssh 的连接状态判断 目标机器的运行状态
        nc -v -z ${ip} ${SSH_PORT} &>/dev/null
        if [ $? -eq 0 ]
        then
            echo -e "\n \033[41;37m ${ip} is in good condition. \033[0m \n" 

            $(pwd)/interact_expect.exp ${ip} ${SSH_PORT} ${SSH_USER} ${SSH_PASSWORD} ${SSH_SUDO_PASSWORD} 

            analyst_statistcal_result
        else
            # 连接超时，发送:服务器状态异常邮件告警
            send_mail "${ip} is not good condition."
        fi

        # 执行完相关命令后，将操作令牌放回
        echo >&3
    }&
done

# 等所有的子进程全部结束
wait

sleep 5
# 关闭文件描述符的读
exec 3<&-
# 关闭文件描述符的写
exec 3>&-

# 打印脚本执行耗时
echo -e "\nThe running time of this script is $SECONDS's\n\n"
exit 0
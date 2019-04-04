#!/bin/bash -
#===============================================================================
#
#          FILE: initial_mysql.sh
#
#         USAGE: ./initial_mysql.sh
#
#   DESCRIPTION: 
#           (1)  利用 expect 和 mysql 交互，删除 test 数据库 和 设置 root 密码
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2018/12/22 21时53分50秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit
set -o pipefail

# 验证 环境变量 是否有效存在
ENVIRONMENT_VARIABLES=(MYSQL_HOME_DIR MYSQL_SOCKET MYSQL_PORT MYSQL_ROOT_PASSWORD)
for variable in ${ENVIRONMENT_VARIABLES[*]}
do
    eval temp=\$${variable}
    if [ "${temp}" == "" ]
    then
        echo -e "\$${variable} is NULL"
        exit 1
    fi
done

# 自动交互需使用 expect 软件，
# 先检测是否安装了(expect 的默认安装路径为: /usr/bin/expect)
if [ ! -f /usr/bin/expect ]
then
	echo -e "expect is not installed"
	echo -e "yum install -y expect tcl"
	exit 0
fi

if [ -f ${MYSQL_HOME_DIR}/bin/mysql ]
then
    # 当安装完后的第一次登陆，是不需要验证密码的
    expect << EOF
        spawn ${MYSQL_HOME_DIR}/bin/mysql --socket=${MYSQL_SOCKET} -u root --port=${MYSQL_PORT}
        expect {
            "*assword:" { send "${MYSQL_ROOT_PASSWORD}\n" }
        }
        expect {
            "mysql>" { send "drop\ database\ if\ exists\ test;\n" }
        }
        expect {
            "mysql>" { send "use mysql;\n" }
        }
        expect {
            "mysql>" { send "update user set password=PASSWORD('${MYSQL_ROOT_PASSWORD}') where user='root';\n" }
        }
        expect {
            "mysql>" { send "flush privileges;\n" }
        }
        expect {
            "mysql>" { send "exit\n" }
        }
        expect eof
EOF
else
    exit 1
fi

exit 0
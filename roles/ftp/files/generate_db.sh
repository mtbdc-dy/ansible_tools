#!/bin/bash -
#===============================================================================
#
#          FILE: generate_db.sh
#
#         USAGE: ./generate_db.sh
#
#   DESCRIPTION: 
#           (1) 虚拟用户模式是一种相比较来说最为安全的验证方式，需要为FTP传输服务单独建立用户数据库文件
#               虚拟出用来口令验证的帐户信息，这些帐号是在服务器系统中不存在的，仅供FTP传输服务做验证使用
#               因此这样即便骇客破解出了帐号口令密码后也无法登录到服务器主机上面，有效的降低了破坏范围和影响
#               所以只要在配置妥当合理的情况下，虚拟用户模式要比匿名登录和本地登录更加的安全
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/03/16 07时18分17秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

if [ ${UID} -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

# 说明:
# DATA_DIR  vsftpd 的数据家目录
# VIRTUAL_USER_FILE ftp登陆的认证用户和密码存放文件
# VIRTUAL_USER_DIR ftp 各个认证用户的配置文件存放目录

# 判断 如下的环境变量是否都已存在
readonly ENVIRONMENT_VARIABLES=(DATA_DIR VIRTUAL_USER_FILE VIRTUAL_USER_DIR CHROOT_LIST)
for variable in ${ENVIRONMENT_VARIABLES[*]}
do
    # 需要用到 shell 高级编程的 "变量间接引用" 技巧
    eval temp=\$${variable}
    if [ "${temp}" == "" ]
    then
        echo -e "\$${variable} is NULL, please setup!"
        exit 1
    fi
done

if [ -f ${VIRTUAL_USER_FILE} ]
then
    if [ -x /usr/bin/db_load ]
    then
        
        father_dir=$(dirname ${VIRTUAL_USER_FILE})
        filename=$(basename ${VIRTUAL_USER_FILE} ".txt")
        cd ${father_dir}

        db_load -T -t hash -f ${VIRTUAL_USER_FILE} ${filename}.db
        if [ $? -eq 0 ]
        then
            # 假如文件中存在注释，则会误删，致使结果集不正确
            user_list=($(cat ${VIRTUAL_USER_FILE} | grep -vE '^#|^$' | awk 'NR%2'))
            if [ ${#user_list[*]} -gt 0 ]
            then
                [ ! -d ${VIRTUAL_USER_DIR} ] && mkdir ${VIRTUAL_USER_DIR}
                for user in ${user_list[*]}
                do
                    cat > ${VIRTUAL_USER_DIR}/${user} << EOF
local_root=${DATA_DIR}/${user}
write_enable=YES
anon_world_readable_only=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
EOF

                mkdir -p ${DATA_DIR}/${user}
                # 授权用户
                echo "${user}" >> ${CHROOT_LIST}

                done
            fi
        else
            echo -e "generate db failed!"
            exit 1
        fi
    else
        echo -e "yum install libdb-utils db4 db4-utils"
        exit 1
    fi
else
    echo -e "用于连接 FTP 的账户和密码文件不存在!"
    exit 1
fi

exit 0
#!/bin/bash -
#===============================================================================
#
#          FILE: compile_nginx.sh
#
#         USAGE: ./compile_nginx.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2018/12/22 11时29分09秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

if [ $UID -ne 0 ]
then
    echo -e "You should switch to root"
    exit 1
fi

# 测试案例
# REMOTE_TEMP_DIR=/tmp
# NGINX_INSTALL_DIR=/usr/local/nginx
# NGINX_SOURCE_CODE=nginx-1.15.6.tar.gz
# PCRE_SOURCE_CODE=pcre-8.40.tar.gz
# OPENSSL_SOURCE_CODE=openssl-1.0.2q.tar.gz
# ZLIB_SOURCE_CODE=zlib-1.2.11.tar.gz
# NGINX_USER=nginx
# NGINX_GROUP=nginx

# 通过 ansible-playbook 注入 环境变量，向该脚本传递参数
ENVIRONMENT_VARIABLES=(REMOTE_TEMP_DIR NGINX_INSTALL_DIR NGINX_SOURCE_CODE PCRE_SOURCE_CODE OPENSSL_SOURCE_CODE ZLIB_SOURCE_CODE NGINX_USER NGINX_GROUP)
for variable in ${ENVIRONMENT_VARIABLES[*]}
do
    eval temp=\$${variable}
    if [ "${temp}" == "" ]
    then
        echo -e "\$${variable} is NULL"
        exit 1
    fi
done

# 检测 nginx 是否已经创建
function check_user()
{
    # TODO
    return 0
}

if [ -d ${REMOTE_TEMP_DIR} ]
then
    cd ${REMOTE_TEMP_DIR}
    if [ -f ${NGINX_SOURCE_CODE} -a -f ${PCRE_SOURCE_CODE} -a -f ${OPENSSL_SOURCE_CODE} -a -f ${ZLIB_SOURCE_CODE} ]
    then
        tar -zxvf ${NGINX_SOURCE_CODE} -C ${REMOTE_TEMP_DIR} > /dev/null 2>&1
        nginx_directory=$(basename ${NGINX_SOURCE_CODE} ".tar.gz")

        tar -zxvf ${PCRE_SOURCE_CODE} -C ${REMOTE_TEMP_DIR} > /dev/null 2>&1
        pcre_directory=$(basename ${PCRE_SOURCE_CODE} ".tar.gz")

        tar -zxvf ${OPENSSL_SOURCE_CODE} -C ${REMOTE_TEMP_DIR} > /dev/null 2>&1
        openssl_directory=$(basename ${OPENSSL_SOURCE_CODE} ".tar.gz")

        tar -zxvf ${ZLIB_SOURCE_CODE} -C ${REMOTE_TEMP_DIR} > /dev/null 2>&1
        zlib_directory=$(basename ${ZLIB_SOURCE_CODE} ".tar.gz")

        if [ -d ${nginx_directory} -a -d ${pcre_directory} -a -d ${openssl_directory} -a -d ${zlib_directory} ]
        then
            cd ${nginx_directory}

            ./configure --prefix=${NGINX_INSTALL_DIR} \
--user=${NGINX_USER} --group=${NGINX_GROUP} \
--with-http_ssl_module --with-http_stub_status_module \
--with-http_v2_module --with-http_gzip_static_module --with-stream \
--with-pcre=${REMOTE_TEMP_DIR}/${pcre_directory} \
--with-openssl=${REMOTE_TEMP_DIR}/${openssl_directory} \
--with-zlib=${REMOTE_TEMP_DIR}/${zlib_directory} > /dev/null

            if [ $? -ne 0 ]; then exit 1; fi
            
            make > /dev/null
            if [ $? -ne 0 ]; then exit 1; fi

            make install > /dev/null
            if [ $? -ne 0 ]; then exit 1; fi

            cd ../
            rm -rf ${nginx_directory} ${pcre_directory} ${openssl_directory} ${zlib_directory}
        else
            echo -e "unarchive *.tar.gz failed!"
            exit 1
        fi
    else
        exit 1
    fi
else
    exit 1
fi

exit 0
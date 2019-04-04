#!/bin/bash -
#===============================================================================
#
#          FILE: compile_httpd.sh
#
#         USAGE: ./compile_httpd.sh
#
#   DESCRIPTION: 
#           (1) 通过注入 环境变量  的方式向该脚本传递运行参数, 分别为:
#               APR_SOURCE
#               APR_INSTALL_DIR
#               APR_UTIL_SOURCE
#               APR_UTIL_INSTALL_DIR
#               APR_ICONV_SOURCE
#               APR_ICONV_INSTALL_DIR
#               APACHE_SOURCE
#               APACHE_INSTALL_DIR
#               APACHE_USER
#               APACHE_GROUP
#               SOURCE_TEMP_DIR
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2018/12/20 09时04分38秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit
set -o pipefail

if [ $UID -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

# 编译过程日志记录
readonly COMPILE_LOG="/tmp/compile_apache.log"
echo "" > ${COMPILE_LOG}

# 判断 如下的环境变量是否都已存在
readonly ENVIRONMENT_VARIABLES=(APR_SOURCE APR_INSTALL_DIR APR_UTIL_SOURCE APR_UTIL_INSTALL_DIR APR_ICONV_SOURCE APR_ICONV_INSTALL_DIR APACHE_SOURCE APACHE_INSTALL_DIR APACHE_USER APACHE_GROUP SOURCE_TEMP_DIR)
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

# 查看安装目录是否已经存在
readonly INSTALL_DIRS=(APR_INSTALL_DIR APR_UTIL_INSTALL_DIR APR_ICONV_INSTALL_DIR APACHE_INSTALL_DIR)
for dir in ${INSTALL_DIRS[*]}
do
    eval temp=\$${dir}
    if [ ! -d ${temp} ]
    then
        echo -e "\$${dir} is not exists!"
        exit 1
    fi
done

# 编译 apr
echo -e "\n \033[31m Starting install apr \033[0m \n" >> ${COMPILE_LOG}
if [ -f ${SOURCE_TEMP_DIR}/${APR_SOURCE} ]
then
    cd ${SOURCE_TEMP_DIR}
    tar -zxf ${APR_SOURCE} -C ${SOURCE_TEMP_DIR}
    directory=$(basename ${APR_SOURCE} ".tar.gz")
    if [ -d ${directory} ]
    then
        cd ${directory}
        ./configure --prefix=${APR_INSTALL_DIR} >> ${COMPILE_LOG} 2>&1
        make >> ${COMPILE_LOG} 2>&1
        make install >> ${COMPILE_LOG} 2>&1

        cd ../
        rm -rf ${directory}
    else
        echo -e "unarchive ${APR_SOURCE} failed!"
        exit 1
    fi
else
    echo -e "${SOURCE_TEMP_DIR}/${APR_SOURCE} is not exists!"
    exit 1
fi

sleep 1

# 编译 apr-iconv
echo -e "\n \033[31m Starting install apr-iconv \033[0m \n" >> ${COMPILE_LOG}
if [ -f ${SOURCE_TEMP_DIR}/${APR_ICONV_SOURCE} ]
then
    cd ${SOURCE_TEMP_DIR}
    tar -zxf ${APR_ICONV_SOURCE} -C ${SOURCE_TEMP_DIR}
    directory=$(basename ${APR_ICONV_SOURCE} ".tar.gz")
    if [ -d ${directory} ]
    then
        cd ${directory}
        ./configure --prefix=${APR_ICONV_INSTALL_DIR} --with-apr=${APR_INSTALL_DIR} >> ${COMPILE_LOG} 2>&1
        make >> ${COMPILE_LOG} 2>&1
        make install >> ${COMPILE_LOG} 2>&1

        cd ../
        rm -rf ${directory}
    else
        echo -e "unarchive ${APR_ICONV_SOURCE} failed!"
        exit 1
    fi
else
    echo -e "${SOURCE_TEMP_DIR}/${APR_ICONV_SOURCE} is not exists!"
    exit 1
fi

sleep 1

# 编译 apr-util
echo -e "\n \033[31m Starting install apr-util \033[0m \n" >> ${COMPILE_LOG}
if [ -f ${SOURCE_TEMP_DIR}/${APR_UTIL_SOURCE} ]
then
    cd ${SOURCE_TEMP_DIR}
    tar -zxf ${APR_UTIL_SOURCE} -C ${SOURCE_TEMP_DIR}
    directory=$(basename ${APR_UTIL_SOURCE} ".tar.gz")
    if [ -d ${directory} ]
    then
        cd ${directory}
        ./configure --prefix=${APR_UTIL_INSTALL_DIR} --with-apr=${APR_INSTALL_DIR} --with-iconv=${APR_ICONV_INSTALL_DIR} >> ${COMPILE_LOG} 2>&1
		make >> ${COMPILE_LOG} 2>&1
        [ $? -ne 0 ] && exit 1

        make install >> ${COMPILE_LOG} 2>&1
        [ $? -ne 0 ] && exit 1

        cd ../
        rm -rf ${directory}
    else
        echo -e "unarchive ${APR_UTIL_SOURCE} failed!"
        exit 1
    fi
else
    echo -e "${SOURCE_TEMP_DIR}/${APR_UTIL_SOURCE} is not exists!"
    exit 1
fi

sleep 1

# 编译 apache
echo -e "\n \033[31m Starting install apache \033[0m \n" >> ${COMPILE_LOG}
if [ -f ${SOURCE_TEMP_DIR}/${APACHE_SOURCE} ]
then
    cd ${SOURCE_TEMP_DIR}
    tar -zxf ${APACHE_SOURCE} -C ${SOURCE_TEMP_DIR}
    directory=$(basename ${APACHE_SOURCE} ".tar.gz")
    if [ -d ${directory} ]
    then
        cd ${directory}
        ./configure \
--prefix=${APACHE_INSTALL_DIR} \
--sysconfdir=${APACHE_INSTALL_DIR}/etc \
--enable-so \
--enable-ssl \
--enable-cgi \
--enable-rewrite \
--enable-modules=most \
--enable-mpms-shared=all \
--with-mpm=prefork \
--with-zlib \
--with-pcre \
--with-apr=${APR_INSTALL_DIR} \
--with-apr-util=${APR_UTIL_INSTALL_DIR}  >> ${COMPILE_LOG} 2>&1

        make >> ${COMPILE_LOG} 2>&1
        make install >> ${COMPILE_LOG} 2>&1

        cd ../
        rm -rf ${directory}
    else
        echo -e "unarchive ${APACHE_SOURCE} failed!"
        exit 1
    fi
else
    echo -e "${SOURCE_TEMP_DIR}/${APACHE_SOURCE} is not exists!"
    exit 1
fi

exit 0
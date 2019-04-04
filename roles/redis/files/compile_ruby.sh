#!/bin/bash -
#===============================================================================
#
#          FILE: compile_ruby.sh
#
#         USAGE: ./compile_ruby.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/29 09时39分41秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

# 源码编译安装需要超级管理权限
if [ ${UID} -ne 0 ]
then
    echo -e "You should switch to root!"
    exit 1
fi

# 编译过程信息输出
readonly COMPILE_INFO=/tmp/compile_ruby.info
echo "" > ${COMPILE_INFO}

declare -ra ENVIRONMENT_VARIABLES=(RUBY_SOURCE_CODE RUBY_INSTALL_DIR RUBYGEM_SOURCE_CODE)
for variable in ${ENVIRONMENT_VARIABLES[*]}
do
    # shell 高级编程中 的 "变量间接引用"
    eval temp=\$${variable}
    if [ "${temp}" == "" ]
    then
        echo "$LINENO: \$${variable} is NULL!"
        exit 1
    fi
done

[ -d ${RUBY_INSTALL_DIR} ] || mkdir -p ${RUBY_INSTALL_DIR}
if [ -f ${RUBY_SOURCE_CODE} ]
then
    base_dir=$(dirname ${RUBY_SOURCE_CODE})
    unarchive_dir=$(basename ${RUBY_SOURCE_CODE} ".tar.gz")

    cd ${base_dir}
    tar -zxf $(basename ${RUBY_SOURCE_CODE}) -C ${base_dir} > /dev/null
    if [ $? -eq 0 -a -d ${unarchive_dir} ]
    then
        cd ${unarchive_dir}
        ./configure --prefix=${RUBY_INSTALL_DIR} --enable-shared > ${COMPILE_INFO} 2>&1
        make > ${COMPILE_INFO} 2>&1
        make install > ${COMPILE_INFO} 2>&1

        cd ../
        rm -rf ${unarchive_dir}

        # 形成软链接，更新 ruby 版本
        [ -x /usr/bin/ruby ] && mv -f /usr/bin/ruby /usr/bin/ruby.old
        [ -x /usr/bin/gem ] && mv -f /usr/bin/gem /usr/bin/gem.old

        ln -s ${RUBY_INSTALL_DIR}/bin/ruby /usr/bin/ruby
        ln -s ${RUBY_INSTALL_DIR}/bin/gem /usr/bin/gem 
        
        # https://gems.ruby-china.com

        if [ -f ${RUBYGEM_SOURCE_CODE} ]
        then
            cd ${base_dir}
            unarchive_dir=$(basename ${RUBYGEM_SOURCE_CODE} ".tar.gz")
            tar -zxf $(basename ${RUBYGEM_SOURCE_CODE}) -C ${base_dir} > /dev/null
            if [ $? -eq 0 -a -d ${unarchive_dir} ]
            then
                cd ${unarchive_dir}
                ${RUBY_INSTALL_DIR}/bin/ruby setup.rb > ${COMPILE_INFO} 2>&1

                cd ../
                rm -rf ${unarchive_dir}
            fi
        fi
    else
        echo -e "unarchive ${RUBY_SOURCE_CODE} failed!"
        exit 1
    fi
else
    echo -e "${RUBY_SOURCE_CODE} is not exist!"
    exit 1
fi

exit 0
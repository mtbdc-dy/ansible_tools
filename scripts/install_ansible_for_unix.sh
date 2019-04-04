#!/bin/bash -
#===============================================================================
#
#          FILE: install_ansible_for_unix.sh
#
#         USAGE: ./install_ansible_for_unix.sh
#
#   DESCRIPTION: 
#           说明: 在 unix 系统上脚本安装 ansible  ===> 由于 ansible 底层使用到 paramiko 模块(ssh 连接),目前我只知道 Windows 下无法正常运行
#       
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/03/19 22时05分17秒
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

# Description: 获取当期系统的发行版本
function get_dist_name()
{
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release
    then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release
    then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release
    then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release
    then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release
    then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release
    then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release
    then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
        PM='unknow'
    fi

    #echo $DISTRO
    return 0
}

get_dist_name

# Description: 发行版安装 ansible 服务
function install_ansible()
{
    # 判断该主机是否能够连接网络
    # local IS_CONNECTED=$(ping -c 2 www.baidu.com > /dev/null 2>&1)
    # if [ $? -ne 0 ]
    # then
    #    echo -e "The host cannot connect to the network!"
    #    return 1
    # fi

    case ${DISTRO} in
        "CentOS" | "RHEL") 
            yum install -y epel-release
            yum clean all
            yum makecache

            local is_installed=$(rpm -qa | grep ansible)
            if [ "${is_installed}" != "" ]
            then
                yum update -y ansible
            else
                yum install -y ansible
            fi
            ;;
        "Debian")
            deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main
            apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
            apt-get update
            apt-get install ansible
            ;;
        "Ubuntu")
            apt-get update
            apt-get install software-properties-common
            apt-add-repository --yes --update ppa:ansible/ansible
            apt-get install ansible
            ;;
        *)
            ;;
    esac

    return 0
}

install_ansible
exit 0
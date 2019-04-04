#!/bin/bash -
#===============================================================================
#
#          FILE: monitor_disk_resource.sh
#
#         USAGE: ./monitor_disk_resource.sh
#
#   DESCRIPTION: 
#           (1) 脚本监控主机的磁盘空间使用率，并阈值告警 ---> 通过邮件服务器
#           (2) 通过 find 命令查找 mtime 设置时间之前的过期日志文件并删除
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/03/14 13时46分27秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit

OLD_IFS=${IFS}
IFS=$'\n'

function get_interface_ip()
{
    # 获取指定网卡的名称
    if [ -f /proc/net/dev ]
    then
        interface_lists=($(cat /proc/net/dev | awk '{i++; if(i>2){print $1}}' | sed 's/^[\t]*//g' | sed 's/[:]*$//g'))
        for interface in ${interface_lists[*]}
        do
            if [ "${interface}" == "eth0" ]
            then
               local interface_name=eth0
               break
            elif [ "${interface}" == "eth1" ]
            then
                local interface_name=eth1
                break
            elif [ "${interface}" == "br0" ]
            then
                local interface_name=br0
                break
            elif [ "${interface}" == "bond0.100" ]
            then
                local interface_name="bond0.100"
                break
            else
               local interface_name="" 
            fi
        done
    fi

    if [ "${interface_name}" == "" ]
    then
       ip=""
       echo "Unable to identify NIC"
       return 0
    fi

    # 获取指定网卡的 IP 地址
    ip=$(ifconfig ${interface_name} | awk '/inet\ /{print $2}')
    echo "${interface_name} ===> ${ip}"
}

function send_mail()
{
    if [ "${ip}" != "" ]
    then
        local title=${1}
        local content="ip: ${ip} =====> ${1}"
        
        local timestamp=$(date +'%s')
        local key=$(echo -n "WEBDUDU_INTERFACE_9237426476824${timestamp}" | md5sum | cut -d ' ' -f1)

        echo "type=web&timestamp=${timestamp}&key=${key}&title=${title}&context=${content}&type=web"
        curl -d "type=web&timestamp=${timestamp}&key=${key}&title=${title}&context=${content}&type=web" "http://dudu.ztgame.com/frontend/Interface/sendWarnMsg" 
    fi

    return 0
}

# 获取主机的磁盘分区信息
function get_disk_partition_info()
{
    # 使用率阈值
    local usage_rate=80

    partition_table=($(df -h | sed -n "2,$ p" | grep -vE "mnt"))
    if [ ${#partition_table[*]} -gt 0 ]
    then
        for partition in ${partition_table[*]}
        do
            every_partition_usage_rate=$(echo "${partition}" | awk '{print $5}' | tr '%' '\0')
            if [ "${every_partition_usage_rate}" != "" -a ${every_partition_usage_rate} -ge ${usage_rate} ]
            then
                local partition_name=$(echo "${partition}" | awk '{print $6}')
                send_mail "The utilization rate of [${partition_name}] is more than ${usage_rate}%"
            fi
        done
    fi
}

function get_oversize_file()
{
    # 单个文件的阈值大小，单位: M
    local size_limit_for_single_file=1024M
    # 目标查询目录
    local find_dir="/log"

    file_list=($(find ${find_dir} -type f -size +${size_limit_for_single_file}))
    if [ ${#file_list[*]} -gt 0 ]
    then
        for file in ${file_list[*]}
        do
            if [ -f ${file} ]
            then
                file_size=$(ls -alh ${file} | awk '{print $5}')
                send_mail "Be careful Hourly Log file is too large. [${file} ${file_size}]"
            fi
        done
    fi
}

get_interface_ip
get_disk_partition_info
get_oversize_file

IFS=${OLD_IFS}
exit 0
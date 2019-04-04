#!/bin/bash -
#===============================================================================
#
#          FILE: check_http_status.sh
#
#         USAGE: ./check_http_status.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/31 15时29分43秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

# 传入的 url 参数
readonly url=$1

function monitor_http()
{
    # -m 设置curl不管访问成功或失败，最大消耗的时间为5秒，5秒连接服务为相应则视为无法连接
    # -s 设置静默连接，不显示连接时的连接速度、时间消耗等信息
    # -o 将curl下载的页面内容导出到/dev/null(默认会在屏幕显示页面内容)
    # -w 设置curl命令需要显示的内容%{http_code}，指定curl返回服务器的状态码
    status_code=$(curl -m 5 -s -o /dev/null -w %{http_code} $url)
    echo $status_code
}

# 调用http监测函数
monitor_http
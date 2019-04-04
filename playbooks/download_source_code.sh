#!/bin/bash -
#===============================================================================
#
#          FILE: download_source_code.sh
#
#         USAGE: ./download_source_code.sh
#
#   DESCRIPTION: 
#           (1) 在各个 role 中，如果源码安装该服务,但是 由于 GitHub 对于 大文件有上传限制, 为避免该种限制
#               则通过脚本在 运行该 playbook 时自动下载所需的源码包
#   
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

if [ $# -ne 0 ]
then
    echo -e "bash $0 download_url"
    exit 1
fi


#!/bin/bash -
#===============================================================================
#
#          FILE: judge_jdk.sh
#
#         USAGE: ./judge_jdk.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/25 10时29分30秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

if [ ${UID} -ne 0 ]
then
    echo -e "You should switch to root"
    exit 1
fi

result=$(grep -rwn --color "^JAVA_HOME=" /etc ~/)
if [ "${result}" != "" ]
then
    echo "yes"
else
    echo "no"
fi

exit 0
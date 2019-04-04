#!/bin/bash -
#===============================================================================
#
#          FILE: control_multithreads_example.sh
#
#         USAGE: ./control_multithreads_example.sh
#   
#   DESCRIPTION: 
#           (1) 管道具有存一个读一个，读完一个就少一个，没有则阻塞，放回的可以重复取，这是队列的特性
#           (2) mkfifo /tmp/$$.fifo    
#               创建有名管道文件exec 3<>/tmp/fd1，创建文件描述符3关联管道文件，
#               这时候3这个文件描述符就拥有了管道的所有特性，还具有一个管道不具有的特性：无限存不阻塞，无限取不阻塞，
#               而不用关心管道内是否为空，也不用关心是否有内容写入引用文件描述符： &3可以执行n次echo >&3 往管道里放入n把钥匙
#           
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/01/03 10时16分37秒
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -o errexit
set -o pipefail

readonly TEMPPIPE=/tmp/$$.fifo

# 判断管道是否存在，如果不存在，则创建
[ -e ${TEMPPIPE} ] || mkfifo ${TEMPPIPE}
# 创建文件描述符，以可读(<)、可写(>) 的方式关联管道文件
exec 3<> ${TEMPPIPE}
# 关联后的文件描述符拥有管道文件的所有特性,可用完删除
rm -rf ${TEMPPIPE}

# 分配的线程总数，默认为 10
readonly THREADS_COUNT=10
for ((i=1;i<=${THREADS_COUNT};i++))
do
    # 引用文件描述符，并往管道里塞入操作令牌
    echo >&3
done

# 业务实现
function execute_command()
{
    # TODO
    return 0
}

# 多线程操作示例
for ((i=1;i<=100;i++))
do
    read -u3
    {
        sleep 1
        echo "Success ${i}"

        execute_command

        # 执行完相关命令后，将操作令牌放回
        echo >&3
    }&
done

wait
sleep 5

echo -e "The time spent running the script: $SECONDS's"
# 关闭文件描述符的读
exec 3<&-
# 关闭文件描述符的写
exec 3>&-

exit 0
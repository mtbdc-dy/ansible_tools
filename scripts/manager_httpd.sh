#! /bin/bash
# chkconfig: 2345 10 90
#===============================================================================
#
#          FILE: manager_httpd.sh
#
#         USAGE: bash manager_httpd.sh start|stop|restart|status|fullstatus|graceful|help|configtest|monitor
#
#   DESCRIPTION:
# 			(1) 脚本管理 apache httpd 服务的启停
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/04/02 15时29分43秒
#      REVISION:  ---
#===============================================================================
set -o nounset                                  # Treat unset variables as an error
set -o errexit

if [ ${UID} -ne 0 ]
then
	echo -e "You should switch to root!"
	exit 1
fi

if [ -f /etc/sysconfig/httpd ]
then
    . /etc/sysconfig/httpd
fi

# httpd 的编译语言环境库
HTTPD_LANG=${HTTPD_LANG-"C"}

INITLOG_ARGS=""

apachectl=/usr/local/apache2/bin/apachectl
httpd=${HTTPD-/usr/local/apache2/bin/httpd}
prog=httpd
pidfile=${PIDFILE-/usr/local/apache2/logs/httpd.pid}
lockfile=${LOCKFILE-/var/lock/subsys/httpd}
RETVAL=0
STOP_TIMEOUT=${STOP_TIMEOUT-10}

function start()
{
    echo -n $"Starting $prog: "
    ${apachectl} -k start
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && touch ${lockfile}

    return $RETVAL
}

function stop()
{
    local pid=$(ps -fu root | grep -v "grep" | grep "${httpd}" | awk '{print $2}')
    if [ "${pid}" != "" ] && [ ${pid} -gt 0 ]
    then
        ${apachectl} -k stop
        RETVAL=$?

        if [ ${RETVAL} = 0 ]
        then
            rm -rf ${lockfile}
            echo -n "Stopped $prog"
        else
             echo -n "Stopped $prog failed."
        fi
    else
        echo -n "$prog is not running."
    fi

	return $RETVAL
}

function status()
{
    local pid=$(ps -fu root | grep -v "grep" | grep "${httpd}" | awk '{print $2}')
    RETVAL=$?
    if [ "${pid}" != "" ] && [ ${pid} -gt 0 ]
    then
		httpd_status="started"
        echo -n "$prog is running(PID ${pid})"
    else
		httpd_status="stopped"
        echo -e "$prog is not running."
    fi

    echo

    return $RETVAL
}

function monitor()
{
	# 获取 httpd 的运行状态
	status
	
	if [ "${httpd_status}" == "stopped" ]
	then
		start
		echo -e "httpd has been restarted!"
	else
		echo -e "httpd started!"
	fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        RETVAL=$?
        ;;
    restart)
        stop
        start
        ;;
    graceful|help|configtest|fullstatus)
        $apachectl $@
        RETVAL=$?
        ;;
	monitor)
		monitor
		;;
    *)
        echo $"Usage: $prog {start|stop|restart|status|fullstatus|graceful|help|configtest|monitor}"
        RETVAL=2
esac

exit $RETVAL
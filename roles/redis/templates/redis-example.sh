#!/bin/sh
#
# redis init file for starting up the redis daemon
#
# chkconfig: - 20 80
# description: Starts and stops the redis daemon.

# Source function library.
if [ -f /etc/rc.d/init.d/functions ]
then
    . /etc/rc.d/init.d/functions
fi

# Source networking configuration.
if [ -f /etc/sysconfig/network ]
then
    . /etc/sysconfig/network
fi

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

readonly redis_home=/usr/local/redis
readonly prog="redis-server"
readonly exec=${redis_home}/${prog}
readonly pidfile="/usr/local/redis-cluster/6380/redis-6380.pid"
# REDIS_CONFIG="/etc/redis.conf"
REDIS_CONFIG="/usr/local/redis-cluster/6380/redis-6380.conf"

[ -e /etc/sysconfig/redis ] && . /etc/sysconfig/redis

lockfile=/var/lock/subsys/redis

start() 
{
    [ -f $REDIS_CONFIG ] || exit 6
    [ -x $exec ] || exit 5
    echo -n $"Starting $name: "
    daemon --user ${REDIS_USER:-redis} "$exec $REDIS_CONFIG"
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() 
{
    echo -n $"Stopping $prog: "
    # stop it here, often "killproc $prog"
    killproc $prog
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile ${pidfile}
    return $retval
}

restart()
{
    stop
    start
}

fdr_status() 
{
    status $prog
}

case "$1" in
    start|stop|restart)
        $1
        ;;
    status)
        fdr_status
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 2
esac
#!/bin/bash -
#===============================================================================
#
#          FILE: operate_ansible.sh
#
#         USAGE: ./operate_ansible.sh
#
#   DESCRIPTION: 
#           (1)
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

if [ $# -ne 1 ]
then
    echo -e "bash $0 apache|init|docker|elk|ftp|haproxy|mysql|nginx|php|python|redis|squid|tomcat|zabbix_agentd|zabbix_server"
    exit 1
fi

# is_installed_ansible=$(ansible --version | grep -iE --color "command\ not\ found")
# if [ "${is_installed_ansible}" == "" ]
# then
#     echo -e "ansible is not installed!"
#     exit 1
# fi

readonly INVNETORY=../inventory/test_hosts.ini
[ ! -f ${INVNETORY} ] && echo -e "${INVNETORY} is not exist!" && exit 1

readonly CHOOSE=$1
case ${CHOOSE} in
    "apache")
        ansible-playbook -i ${INVNETORY} deploy_apache.yaml
        ;;
    "init")
        ansible-playbook -i ${INVNETORY} initial_system.yaml
        ;;
    "docker")
        ansible-playbook -i ${INVNETORY} deploy_docker.yaml
        ;;
    "elk")
        ansible-playbook -i ${INVNETORY} ./deploy_elk.yaml
        ;;
    "ftp")
        ansible-playbook -i ${INVNETORY} ./deploy_ftp.yaml
        ;;
    "haproxy")
        ansible-playbook -i ${INVNETORY} ./deploy_haproxy.yaml
        ;;
    "mysql")
        ansible-playbook -i ${INVNETORY} ./deploy_mysql.yaml
        ;;
    "nginx")
        ansible-playbook -i ${INVNETORY} ./deploy_nginx.yaml
        ;;
    "php")
        ansible-playbook -i ${INVNETORY} ./deploy_php.yaml
        ;;
    "python")
        ansible-playbook -i ${INVNETORY} ./deploy_python.yaml
        ;;
    "redis")
        ansible-playbook -i ${inventory} ./deploy_redis.yaml
        ;;
    "squid")
        ansible-playbook -i ${INVNETORY} ./deploy_squid.yaml
        ;;
    "tomcat")
        ansible-playbook -i ${INVNETORY} ./deploy_tomcat.yaml
        ;;
    "zabbix_agentd")
        ansible-playbook -i ${INVNETORY} ./deploy_zabbix_agentd.yaml
        ;;
    "zabbix_server")
        ansible-playbook -i ${INVNETORY} ./deploy_zabbix_server.yaml
        ;;
    *)
        echo -e "The ${CHOOSE} is not implemented!"
        ;;
esac

exit 0
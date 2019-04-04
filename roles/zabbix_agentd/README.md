Role Name
=========

通过源码/管理器安装 `zabbix_agentd`

Requirements
------------

source version | download url | package |
:- | :- | :- |
zabbix-3.4.15.tar.gz | <https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.4.15/zabbix-3.4.15.tar.gz> |
zabbix-centos6 | <https://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-release-3.0-1.el6.noarch.rpm> | zabbix-server-mysql zabbix-web-mysql zabbix-agent |
zabbix-centos7 | <https://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm> | zabbix-server-mysql zabbix-web-mysql zabbix-agent |

Role Variables
--------------

配置参数 均在 `inventory/group_vars/all.yaml` 和 `./defaults/main.yaml` 中进行设置

Dependencies
------------

对于 zabbix_agentd 的源码编译安装，需要系统具有  `gcc,gcc-c++,make` 等系统工具，如果需要具有公网的访问能力，则设置 `dependency_common` 为 `true`

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      remote_user: ansible_ssh_user
      become: yes
      become_method: su
      gather_facts: True

      roles:
        - role: zabbix_agentd
          tags: zabbix_agentd

    ``` shell
      $ cd scripts
      $ INVENTORY=../inventory/hosts.ini ./deploy_zabbix_agentd.yaml
    ```

> 说明:
> * 当前仅已完成 主动/被动模式下 的 `zabbix-server/zabbix-agentd` 的安装, 后续会支持 `zabbix-server/zabbix-proxy/zabbix-agentd` 的功能
> * 当 使用 `packageManager` 模式安装时，需要设置 `defaults/main.yaml` 的 `zabbix_repository_url` 变量为符合主机环境的 rpm 包
> * 建议使用 源码包进行编译安装

License
-------

BSD

Author Information
------------------

欢迎发送邮件交流 ansible 的使用,邮箱为: <1318895540@qq.com>

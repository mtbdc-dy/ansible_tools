Role Name
=========

进行 Linux 操作系统的设置

* 设置 `http_proxy` 和 `https_proxy` 环境变量
* 添加 163 repository
* 安装系统开发工具和更新系统
* 设置 `inventory/hosts.ini` 中的主机之间免密码登陆 (如果 hosts.ini 的 all 组主机数大于 1)
* 关闭 `selinux` 和 `swapoff`
* modprobe 相关的内核模块、设置相关的内核参数后 sysctl -p 使之生效
* 设置 ntpdate 时间同步
* 设置 `/etc/security/limits.conf` 的资源使用
* 设置 `iptables/firewalld`
* 启/停相关服务: `firewalld,iptables,ntpdate` 等
* 设置主机名
* 设置 `主机名` 和 `IP` 的对应关系

Requirements
------------

Role Variables
--------------

该 `role` 的所有变量参数均在文件 `inventory/group_vars/all.yaml` 和 `./defaults/main.yml` 中设置

Dependencies
------------

如果需要设置 `http_proxy` 和 `https_proxy` 环境变量，假如在局域网环境下，则设置 `dependencies_squid` 为 `true`

    dependencies:
      - { role: squid, when: dependencies_squid }

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

License
-------

BSD

Author Information
------------------

欢迎发送邮件交流 ansible 的使用,邮箱为: <1318895540@qq.com>

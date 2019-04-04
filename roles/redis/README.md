Role Name
=========

redis 安装、cluster 配置、ruby、rubygem 安装

Requirements
------------

redis-cluster 集群中的某一台宿主机上安装ruby和rubygem，用于自带 `redis-trib.rb` 的集群自发现执行

Role Variables
--------------

所有的变量均在 `inventory/group_vars/all.yaml` 和 `defaults/main.yaml` 中设置

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: redis
      roles:
         - { role: redis-cluster }

TroubleShooting
----------------

* 修改 `ruby` 的国内源 <https://gems.ruby-china.com>

> 说明:
> 当前剧本只进行了 redis 应用程序的编译，后分发至各目标节点。redis 目标节点均安装 `ruby` 和 `rubygem`
> 针对 redis 特性，对目标主机的操作系统进行相应的调优

License
-------

BSD

Author Information
------------------

欢迎发送邮件交流 ansible 的使用,邮箱为: <1318895540@qq.com>

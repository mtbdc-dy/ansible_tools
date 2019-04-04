Role Name
=========

源码编译安装 `nginx`

Requirements
------------

source version | download url |
:- | :- |
nginx-1.15.6.tar.gz | <http://nginx.org/download/nginx-1.15.6.tar.gz> |
openssl-1.0.2p.tar.gz | <https://www.openssl.org/source/old/1.0.2/openssl-1.0.2p.tar.gz> |
pcre-8.40.tar.gz | <http://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz> |
zlib-1.2.11.tar.gz | <http://www.zlib.net/fossils/zlib-1.2.11.tar.gz> |

Role Variables
--------------

参数均在配置文件 `inventory/group_vars/all.yaml` 和 `defaults/main.yaml` 中设置

Dependencies
------------

在编译过程中，其需要 `yum,gcc,wget,gcc-c++,make` 等系统工具，需要目标主机具有访问公网的能力，则可以设置 `dependency_common` 为 `true`

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: webserver
      remote_user: ansible_ssh_user
      become: yes
      become_method: su
      gather_facts: True

      roles:
        - role: nginx
          tags: nginx

  ``` shell
  Usage:
    $ cd scripts
    $ INVENTORY=../inventory/hosts.ini ./deploy_nginx.sh
  ```

License
-------

BSD

Author Information
------------------

欢迎发送邮件交流 ansible 的使用,邮箱为: <1318895540@qq.com>
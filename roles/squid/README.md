Role Name
=========

安装 squid 缓存代理服务器，便于局域网环境下的其他主机能够通过该代理访问公网

Requirements
------------

source version | download url |
:- | :- |
squid-3.5.28.tar.gz | <http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.28.tar.gz> |

Role Variables
--------------

均在 `inventory/group_vars/all.yaml` 和 `./defaults/main.yaml` 中设置

Dependencies
------------

`openssl openssl-devel`

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: squid
      remote_user: ansible_ssh_user
      become: yes
      become_method: su
      gather_facts: True

      roles:
        - role: squid
          tags: squid

  ``` shell
    Usage:
      $ cd scripts
      $ INVENTORY=../inventory/hosts.ini ./deploy_squid.sh
  ```

License
-------

BSD

Author Information
------------------

欢迎交流 ansible 的使用,邮箱 <1318895540@qq.com>

------------------

TroubleShooting
------------------------

* 当通过代理访问时，出现错误 `500 Internal Server Error`

  配置文件中的 `never_direct`	指令导致，将其注释重启即可

Role Name
=========

利用 源码/包管理器 进行 apache http 的批量安装

Requirements
------------

source version | download url |
:- | :- |
apr-1.6.3.tar.gz | <http://archive.apache.org/dist/apr/apr-1.6.3.tar.gz> |
apr-iconv-1.2.2.tar.gz | <http://mirrors.tuna.tsinghua.edu.cn/apache//apr/apr-iconv-1.2.2.tar.gz>|
apr-util-1.6.1.tar.gz | <http://mirrors.tuna.tsinghua.edu.cn/apache//apr/apr-util-1.6.1.tar.gz>|
httpd-2.4.34.tar.gz | <http://archive.apache.org/dist/httpd/httpd-2.4.34.tar.gz> |

Role Variables
--------------

该 `role` 的变量参数均在 `./defaults/main.yaml` 和 `inventory/group_vars/all.yaml` 中设置,请使用者根据实际环境自行修改

Dependencies
------------

由于在安装过程中,源码编码需要使用 `yum` 安装 `gcc,gcc-c++,make` 等基础环境工具,所以需要具有访问公网的能力,则设置 `dependencies_common` 为 `true`

      dependencies:
        - { role: common, when: dependencies_common }
  
Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: webserver
      remote_user: ansible_ssh_user
      become: yes
      become_method: su
      gather_facts: True

      roles:
        - role: apache
          tags: apache

  ``` shell
  Usage:
    $ cd scripts
    $ INVENTORY=../inventory/hosts.ini ./deploy_apache.sh
  ```

TroubleShooting
---------------
* `xml/apr_xml.c:35:19: fatal error: expat.h: No such file or directory`
  ```shell
  yum install expat-devel
  ```

* `configure: error: pcre-config for libpcre not found. PCRE is required and available from http://pcre.org/`
  ```shell
  yum install pcre pcre-devel
  ```

License
-------

BSD

Author Information
------------------

欢迎发送邮件交流 ansible 的使用,邮箱为: <1318895540@qq.com>

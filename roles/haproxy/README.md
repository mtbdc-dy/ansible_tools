Role Name
=========

keepalive + haproxy 实现 应用的高可用和负载均衡

Requirements
------------

| haproxy version| download url |
| :-: | :- |
| haproxy-1.8.17.tar.gz | <http://www.haproxy.org/download/1.8/src/haproxy-1.8.17.tar.gz> |

Role Variables
--------------

* 变量参数均在 `inventory/group_vars/all.yaml` 和 `defaults/main.yaml` 中配置,如果想灵活配置,请修改配置文件
* 对于 haproxy.cfg 中的负载均衡后台代理,请根据实际环境设置

  ```conf
  #---------------------------------------------------------------------
  # round robin balancing between the various backends
  #---------------------------------------------------------------------
  backend web_server
    balance     roundrobin
    option httpchk HEAD /index.html HTTP/1.0
    option forwardfor    #后端服务获得真实ip
    option httpclose     #请求完毕后主动关闭http通道
    option abortonclose  #服务器负载很高，自动结束比较久的链接

    # 以下为测试样例,请根据实际生产环境设置
    {% for host in groups['tomcat'] %}
    server app{{ host | regex_replace('[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.','') }} {{ host }}:8080 check inter 9000 rise 3 fall 3
    {% endfor %}
  ```

Dependencies
------------

| | |
| :-: | :-: |
| make | cmake |
| automake | gcc |
| gcc-c++ | glibc |
| glibc-devel | openssl |
| openssl-devel | pcre |
| pcre-devel | zlib |
| zlib-devel |

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: haproxy
      remote_user: ansible_ssh_user
      become: yes
      become_method: su
      gather_facts: True

      roles:
        - role: haproxy
          tags: haproxy

  ```shell
  $ cd scripts
  $ INVENTORY=../inventory/hosts.ini ./deploy_haproxy.sh
  ```

TroubleShooting
---------------

* 启动过程中,报如下错误

  ```shell
  [ALERT] 025/182213 (9117) : parsing [/usr/local/haproxy/etc/haproxy.cfg:63] : 'frontend' cannot handle unexpected argument '*:5000'.
  [ALERT] 025/182213 (9117) : parsing [/usr/local/haproxy/etc/haproxy.cfg:63] : please use the 'bind' keyword for listening addresses.
  [ALERT] 025/182213 (9117) : Error(s) found in configuration file : /usr/local/haproxy/etc/haproxy.cfg
  [ALERT] 025/182213 (9117) : Fatal errors found in configuration.
  Errors in configuration file, check with haproxy check.
  ```

External Resources
------------------

* [configuration.txt](configuration.txt)
* [intro.txt](intro.txt)
* [management.txt](management.txt)

License
-------

BSD

Author Information
------------------

欢迎交流 ansible 高级用法,邮箱: <1318895540@qq.com>

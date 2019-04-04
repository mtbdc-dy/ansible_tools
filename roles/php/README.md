Role Name
=========

源码包/包管理器 安装 PHP 服务

Requirements
------------

| source version | download url |
| :- | :- |
| libiconv-1.15.tar.gz | <http://mirror.hust.edu.cn/gnu/libiconv/libiconv-1.15.tar.gz> |
| libmcrypt-2.5.7.tar.gz | <https://jaist.dl.sourceforge.net/project/mcrypt/Libmcrypt/Production/libmcrypt-2.5.7.tar.gz> |
| libxml2 | <http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz> |
| php-5.6.37.tar.gz | <http://cn2.php.net/distributions/php-5.6.37.tar.gz> |

Role Variables
--------------

参数均在配置文件 `inventory/group_vars/all.yaml` 和 `defaults/main.yaml` 中设置

Dependencies
------------

* 在编译过程中,需要目标主机具有访问公网的能力,并通过 `yum` 安装如下的依赖组件

| 依赖组件 | 依赖组件 |
| :- | :- |
| autoconf | automake
| bison | bison-devel
| bzip2 | bzip2-devel
| curl | libcurl-devel
| flex | flex-devel
| freetype | freetype-devel
| gd | gd-devel
| glibc | glibc-devel
| libjpeg-turbo | libjpeg-turbo-devel
| libpng | libpng-devel
| libtool | libxml2
| libxml2-devel | libxslt
| libxslt-devel | openldap
| openldap-devel | openssl
| openssl-devel | pcre
| pcre-devel |

* 源码编译 PHP,过程依赖 `mysql` 和 `apache`,如果目标主机未安装该服务,则可在 `defaults/main.yaml` 中 设置

  ```yaml
  dependencies_common: true
  dependencies_mysql: true
  dependencies_apache: true
  dependencies_nginx: true
  ```

* 样例编译参数

  ```shell
  # PHP 编译参数
  ./configure --prefix=/usr/local/php \
  --with-config-file-path=/usr/local/php/etc \
  --with-mysqli=/usr/local/mysql/bin/mysql_config \
  --with-mysql-sock=/usr/local/mysql/running_info/mysql.sock \
  --with-pdo-mysql=/usr/local/mysql \
  --with-libxml-dir=/usr/local/php/libxml \
  --with-gd --with-snmp \
  --enable-bcmath --enable-shmop \
  --enable-sysvsem --enable-inline-optimization \
  --enable-opcache --enable-mbregex \
  --enable-fpm --enable-mbstring \
  --enable-ftp --enable-gd-native-ttf \
  --with-openssl --enable-pcntl \
  --enable-sockets --with-xmlrpc \
  --with-zlib --with-ldap \
  --enable-zip --enable-soap --without-pear \
  --with-gettext --enable-session \
  --with-freetype-dir \
  --with-jpeg-dir \
  --with-iconv=/usr/local/php/libiconv \
  --with-mcrypt=/usr/local/php/libmcrypt \
  --with-curl --enable-ctype --enable-mysqlnd \
  --with-apxs2=/usr/local/apache_web/httpd/bin/apxs
  ```

  > 由于不同版本的 php 的 `./configure` 后接参数不同, 请使用者自行测试修改 别的版本的 `./configure`

* 编译过程可在目标主机的 `/tmp/compile_php.info` 中查看详细信息

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: php
      remote_user: ansible_ssh_user
      become: yes
      become_method: su
      gather_facts: True

      roles:
        - role: php
          tags: php

  ``` shell
    Usage:
      $ cd scripts
      $ INVENTORY=../inventory/hosts.ini ./deploy_php.sh
  ```

TroubleShooting
---------------

* 在编译 PHP 时，出现以下问题，

  ```shell
  /usr/bin/ld: ext/ldap/.libs/ldap.o: undefined reference to symbol 'ber_scanf'
  /usr/lib64/liblber-2.4.so.2: error adding symbols: DSO missing from command line collect2: error: ld returned 1 exit status
  make: *** [sapi/cli/php] Error 1

  解决方法:  在执行 ./configure 后
  vim Makefile   
  搜索开头是 'EXTRA_LIBS' 这一行在结尾加上 '-llber' 然后执行 make && make install
  ```

* 在 make 时出现 `libxml.c:14:20: 致命错误:Python.h:没有那个文件或目录`
  ```shell
  yum install python-devel
  ```

* 在执行完 `make install` 后,需要执行 `libtool --finish /tmp/php-5.6.39/libs`

  

License
-------

BSD

Author Information
------------------

欢迎邮件交流 ansible 的使用, 邮箱 <1318895540@qq.com>
vsftpd
=========

centos6/7 通过用户交互输入选择安装的类型

![avatar](pictures/deploy_ftp.png)

Requirements
------------

| software | download url |
| :- | :- |
| vsftpd | <https://fossies.org/linux/misc/vsftpd-3.0.3.tar.gz> |
| 

Role Variables
--------------

通过 defaults/main.yaml 文件定义 ftp 所需的所有变量参数

Dependencies
------------

Example Playbook
----------------

安装过程
-------

* `deploy_ftp.yaml` 中通过 `vars_prompt` 来让用户交互选择安装 `vsftp/sftp` 类型
* 安装依赖环境

  ```shell
  yum -y install gcc gcc-c++ db4-utils pam-devel libcap
  ```

* 首先创建 ftp 用户组 `groupadd ftp`
* 下载源码包，并修改编译

  ```shell
  wget https://security.appspot.com/downloads/vsftpd-3.0.2.tar.gz
  tar -zxf vsftpd-3.0.2.tar.gz
  cd vsftpd-3.0.2
  vi builddefs.h

    #define VSF_BUILD_TCPWRAPPERS             //允许使用TCP Wrappers（默认是undef）
    #define VSF_BUILD_PAM                     //允许使用PAM认证
    #define VSF_BUILD_SSL                     //允许使用SSL（默认是undef）

  sed -i 's/lib\//lib64\//g' vsf_findlibs.sh
  make && make install
  
  mkdir /etc/vsftpd/
  cp vsftpd.conf /etc/vsftpd/vsftpd.bak
  cp RedHat/vsftpd.pam /etc/pam.d/vsftpd
  ```

  `vim /etc/vsftp/vsftpd.conf`

  ```vim
  #关闭匿名访问
  anonymous_enable=NO

  #启用本地系统用户，包括虚拟用户
  local_enable=YES

  #允许执行FTP命令，如果禁用，将不能进行上传、下载、删除、重命名等操作
  write_enable=YES

  #本地用户umask值
  local_umask=022

  dirmessage_enable=YES

  #启用日志
  xferlog_enable=YES

  xferlog_std_format=YES

  #关闭ftp-data端口，相当于不使用主动模式
  connect_from_port_20=NO

  #限制用户不能离开FTP主目录，启用并设置例外用户清单
  chroot_local_user=YES
  chroot_list_enable=NO
  chroot_list_file=/etc/vsftp/chroot_list

  ascii_upload_enable=YES
  ascii_download_enable=YES

  #使用ipv4进行监听
  listen=YES
  listen_ipv6=NO

  #pam认证文件名称，位于/etc/pam.d/
  pam_service_name=vsftpd

  #启用全局用户例外清单
  userlist_enable=YES
  userlist_file=/etc/vsftp/user_list

  #启用tcp封装
  #tcp_wrappers=YES

  #虚拟用户权限是否与本地用户相同。为NO时，将与匿名用户的权限相同，在每个虚拟用户配置文件里设置匿名用户的选项等于虚拟用户的权限
  virtual_use_local_privs=YES

  #启用guest后，所有非匿名用户将映射到guest_username进行访问，包括本地系统用户也不能使用，并且转换成一个虚拟用户，与其他虚拟用户的配置方法一样
  guest_enable=YES
  guest_username=ftpuser

  #虚拟用户配置文件目录
  user_config_dir=/etc/vsftp/virtual_user_dir

  allow_writeable_chroot=YES

  #启用pasv模式
  pasv_enable=YES
  pasv_min_port=11100
  pasv_max_port=11200
  ```

* 修改 `sed -i "s/disable                 = no/disable                 = yes/" /etc/xinetd.d/vsftpd`
* 

问题说明
-------

* 通过源码编译安装 `vsftp-3.0.2.tar.gz` 后，通过命令行 `/usr/local/sbin/vsftpd &` 启动，连接会报 如下错误，但通过 `service vsftpd start` 则正常

  ```problem
  530 This FTP server is anonymous only.
  Login failed
  ```

* 经测试,在 `centos7` 平台上源码编译安装后，通过命令 `systemctl start vsftpd` 会出现卡死后超时退出现象,为规避该种错误,则通过 编写 `vsftpd.sh` 脚本启停服务

  ```centos7
  centos7 平台:  /etc/rc.d/init.d/vsftpd start|restart|stop
  ```

  ```centos6
  在 centos6平台:  service vsftpd start|restart|stop
  ```

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).

运维与开发
========

> 工具、编码、设计模式的综合运用

DevOps 自动化运维工作技能
----------------------

* CentOS-6/7 批量安装(PXE+kickstart)、基础设置(网络配置、安全防护、内核参数调整、用户添加/删除、权限设置、基础服务安装/配置等)、故障诊断(各种小工具的使用)
* 版本管理(Git/SVN)：分支策略、基础命令使用(初始化、克隆、提交、回滚、分支创建/删除/合并、日志查看 等)
* CI (Jenkins) 使用(搭建、用户创建/权限分配、插件安装/配置、master/slave 设置、升级/备份/恢复)、pipeline 的编写，流程测试(ocean)
* 自动化测试(XUnit 单元测试、性能测试、前端框架测:selenium)
* ansible 的使用(架构原理，API调用、playbook 编写、目录结构、变量定义和引用、inventory 动态生成、yaml 语法)
* 统一日志平台(Elasticsearch、Logstash、Kibana)、Rsyslog + logrotate
* 虚拟化环境(Vmware ESXI, Docker 基础命令使用、私服搭建)
* zabbix 监控(安装、配置、告警筛选、数据表分区、主动模式、模版编写)
* Haproxy 高可用安装、配置、监控
* Nginx 安装、配置(反向代理、负载均衡、重定向、防火墙设置、虚拟主机配置、)、调优
* redis-cluster 安装、配置、调优、原理理解
* Tomcat 基础(MaxQueue、Maxthreads、热升级等)
* 网络基础知识
* shell/python 脚本编程
* mysql 数据库(主从结构、复制原理、基础调优、基础 sql 使用)
* 防火墙技术(iptables 的使用、原理)

redis 知识点(使用和原理)
---------------------

* redis 是什么？说说优缺点？
  * redis 是一种单线程、使用 epoll I/O 多路复用模型，并基于内存存储的 key-value 型的非关系型数据库
    * 优点:
      * 基于内存存储,读写速度特别快(一般内存的响应时间为 100ns)
      * 采用 单线程,没有线程的上下文切换和锁竞争等待时间消耗,操作速度很快
      * 基于键值对的数据结构服务器
      * 丰富的 API 接口和数据类型(terminal支持的命令很多, 数据类型: string,list,hash,set,zset,bitmaps,hyperloglog,GEO)提供键过期功能、简单的发布订阅功能、支持 lua 脚本扩展、简单的事务功能、提供了批处理功能: pipeline
      * 简单稳定，使用 C 语言实现，代码精简
      * 提供了主流编程语言的客户端实现
      * 能够持久化数据(RDB 和 AOF)
      * 提供主从复制，从而具有高可用和分布式的特性
    * 缺点:
      * 由于是单线程模型，容易出现阻塞(比如: 持久化时的 fork 操作，aof 的追加操作)
      * 主从复制的性能问题: 当主从节点是跨机房时，由于网络的稳定性影响，主从复制的速度和连接的稳定性易受影响
    > 说明: `epoll` 模型 和 `select` 的对比优缺点(能够详细说明，加分项)

* redis 与 memcached 相比的优势？
  * memcached 所有的值均是简单的字符串，redis作为其替代者，支持更为丰富的数据类型
  * redis 的速度比 memcached 快很多
  * redis 可以持久化其数据

* redis 支持哪几种数据类型
  * string: 内部实现自定义的一个 simple dynamic string 结构体
    * 内部编码: int(8字节长整形)、embstr(<= 39 字节的字符串)、raw(> 39 字节的字符串)
    * 使用场景: 缓存、计数、共享 session、限速
  * hash: 指键值本身又是一个键值对的数据结构
    * 内部编码: ziplist(hash-max-ziplist-entrie(默认为 512 个) 和 hash-max-ziplist-value(默认为 64个字节) 控制): 连接的内存空间，很节省内存
    * 使用场景: hashtable (读写的时间复杂度 O(1))
  * list: 用来存储多个有序的字符串
    * 内部编码:
      * ziplist(list-max-ziplist-entries 和 list-max-ziplist-value 控制编码)
      * linkedlist:
      * quicklist:
    * 使用场景: 消息队列、文章列表、
  * set: 用来保存多个字符串元素、集合中不允许有重复元素、集合中的元素是无序的、不能通过索引下标获取元素
    * 内部编码: intset(set-max-intset-entries 控制)、hashtable
    * 使用场景: 用户添加标签、添加用户等
  * zset: 集合元素不能重复、但可以通过 score 来进行排序
    * 内部编码: ziplist(zset-max-ziplist-entries(默认为 128 个) 和 zset-max-ziplist-value(默认为 64个字节))
    * 使用场景: 社交中的用户点赞数、订阅用户

* redis 主要消息那些物理资源？
  * redis 为基于内存的键值对存储，所有的对象均存在内存
  * redis 为 CPU 密集型服务
  * redis 集群的主从复制，会消耗 网络带宽

* 一个字符串类型的值能够存储的最大容量为？ `string'value <= 512M`

* 如何将 redis 放在应用程序中？ <https://blog.csdn.net/wang258533488/article/details/78901124>
  * 作为一款性能优异的内存数据库
    * 分布式锁          <https://blog.csdn.net/wang258533488/article/details/78913800>
    * 接口限流器        <https://blog.csdn.net/wang258533488/article/details/78913827>
    * 订单缓存: 使用Redis的zset数据结构存储每个用户的订单，按照下单时间倒序排列，用户唯一标识作为key，用户的订单集合作为value，使用订单创建时间的时间戳+订单号后三位作为分数
    * redis 和 DB 数据一致性处理
    * 防止缓存穿透和雪崩: 关键是 使用分布式锁和锁的粒度控制
    * 分布式 session 共享

* 什么是CAP理论？(consistency,partition tolerance,availability)       <http://www.cnblogs.com/xybaby/p/6871764.html>

* 持久化原理？
  * RDB: 当建立主从连接时，其 bgsave 保存紧凑的二进制文件，psync 发送到 slave 节点

    ```shell
    bgsave ---> 父进程(有其他子进程正在执行，直接返回) ---> fork 操作 ---> 主线程响应其他命令
                                                        |
                                                        |
                                             子进程 生成 rdb 文件，完成后信号通知 父进程
    ```

    * 优缺点:
      * rdb 是一个紧凑压缩的二进制文件，常用于拷贝 RDB 文件然后灾难备份/恢复
      * redis 加载 RDB 恢复数据远远快于 AOF 方式
      * RDB 方式数据没办法做到实时持久化/秒级持久化
      * RDB 文件使用特定二进制格式保存，兼容性较差
  * 持久化到 本地时，bgrewriteaof 不易造成阻塞

    ```shell
    bgrewriteaof ---> 父进程 ---> fork 子进程 ---> 发信号给父进程
                                /         \
                               /           \
                           aof_buf    aof_rewrite_buf ---> 新的 AOF 文件
                              |                               |
                              |                               |
                           旧的 AOF 文件  <---------------------
    ```

    * 过程说明:
      * 执行 AOF 重写请求(bgrewriteaof 命令)
      * 父进程执行 fork 创建子进程,开销等同于 bgsave 过程,主进程 fork 操作完成后，继续响应其他命令。所有的修改命令依然写入 AOF 缓冲区并根据 appendfsync(always,everysec,none) 策略同步到硬盘,由于 fork 操作运用写时复制技术，子进程只能共享 fork 操作时的内存数据、由于父进程依然响应命令，redis 使用 “AOF重写缓冲区”保存这部分数据
      * 子进程根据内存快照，按照命令合并规则写入到新的 AOF 文件。每次批量写入硬盘数据量由配置 aof-rewrite-incremental-fsync 控制,默认为 32M
      * 新的 AOF 文件写入完成后，子进程发送信号给父进程，父进程更新统计信息
      * 父进程把 AOF 重写缓冲区的数据写入到新的 AOF 文件
      * 使用新的 AOF 文件替换老文件，完成 AOF 重写

* redis 的主从复制原理？ 均在 slave 节点上进行
  * 执行完 slaveof [master ip] [master port]
    * 保存 主节点(master) 的信息
    * 建立 socket 连接
    * 发送 ping 命令
      * 为了验证 网络的稳定性和可用
      * 为了验证 master 节点能够处理命令,不在阻塞状态
    * 权限认证(如何配置了密码,则 master: config set requirepass, slave: config set masterauth)
    * 同步数据集
        全量负责: 第一次建立主从连接
        部分复制:
    * 命令持续复制

* redis 集群方案？
  * redis-cluster 的设计
    * 所有的redis节点彼此互联(PING-PONG机制),内部使用二进制协议优化传输速度和带宽
    * 节点的fail是通过集群中超过半数的节点检测失效时才生效
    * 客户端与redis节点直连,不需要中间proxy层.客户端不需要连接集群所有节点,连接集群中任何一个可用节点即可
    * redis-cluster把所有的物理节点映射到[0-16383]slot上（不一定是平均分配）,cluster 负责维护node<->slot<->value

  * redis-cluster 的自动化安装(编写 ansible-playbook)
  * twemproxy 中间件: 在 应用程序和后端集群之间添加一个中间件(由其负责数据切片和访问路由)   <https://github.com/twitter/twemproxy>
  * sentinel 哨兵模式

* redis 集群运维?
  * 集群安装(ansible-playbook)
  * 操作系统的优化(内存、CPU、网络栈、硬盘)
    * 内存分配控制: vm.overcommit_memory=1
      * swappiness:

        ```shell
        cat /proc/redis-pid/smaps | grep Swap
        echo {best-value} > /proc/sys/vm/swappiness
        echo vm.swappiness={best-value} >> /etc/sysctl.conf
        ```

      * THP:

        ```shell
        echo never > /sys/kernel/mm/transparent_hugepage/enabled
        ```

      * OOM killer:

        ```shell
        echo {value} > /proc/{redis-pid}/oom_adj
        ```

      * 使用 ntp 同步系统时
      * ulimit:

        ```shell
        ulimit -a
        ulimit -Sn {max-open-files}
        ```

      * TCP backlog:

        ```shell
        cat /proc/sys/net/core/somaxconn
        echo 511 > /proc/sys/net/core/somaxconn
        ```

      * 以普通用户 启动 redis-cluster、设置 dir,dbfilename、设置密码机制、防火墙开启端口通过、bind 绑定地址、定期备份等

      * redisObject 内部实现:

        ```object
        type: 4 bytes
        encoding: 4 bytes
        lru: REDIS_LRU_BITS  最后访问时间
        int refcount: 引用的计数器
        void * ptr: 内存数据地址指针
        ```

        ```shell
        redis 的内存消耗: 自身内存、对象内存、缓冲内存(aof_buf,aof_rewrite_buf)、内存碎片(比如 string 中的内部实现 SDR 的内存预分配)
        缩减键值对象: 满足业务需求情况下的 key 描述、value 数据类型
        共享对象池: 0-9999 个整形数字
        字符串优化: 利用高效的工具 序列化 字符串为二进制数据存储
        编码优化: 调整 list,hash,set,zset 的 元素个数和 元素中的value 的字节数大小，从而选用合适的编码实现
        控制键的数量: 可以利用 hash 算法，对 key 进行运算，然后均分到不同的 节点 上
        ```

      * 集群的使用(恰当的 API 操作(mget,mset,pipeline 等)、数据模型的选用、新增节点/缩减节点)
      * redis 的事务功能(multi,discard/exec)
      * redis 的内存回收策略(设置 maxmemory,删除过期键:惰性删除/定时任务删除)
        * noeviction:
        * volatile-lru:
        * allkeys-lru:
        * allkeys-random:
        * volatile-random:
        * volatile-ttl:
      * 常见的阻塞原因分析
        * 查看日志和 系统的性能分析小工具(iostat,vmstat,free,top)
        * 分析代码: 是否使用了不恰当的 API 和数据类型
        * CPU 是否饱和(持久化操作很消耗 CPU)
        * 持久化操作阻塞
        * 内存不足
        * 网络问题
          * 网络闪断: sar -n DEV 和 监控系统的联合分析
          * redis 拒绝连接: maxclients(默认 10000)
          * 连接溢出
          * 系统运行进程打开的文件数(ulimit -n 65535)
          * 网卡的 backlog 队列溢出
          * 网络延迟
            `redis-cli -h localhost -p 6379 --latency`
          * 网卡软中断 top + 数字 1
      * 据槽的概念和配置(新增/删除节点，数据迁移)

* redis 与 关系型数据库的联合使用(mysql)

Linux 主机相关
-------------

* PXE + kickstart 批量 安装 Linux 系统  <https://www.cnblogs.com/f-ck-need-u/p/6442024.html>
  * Client 向PXE Server上的DHCP发送IP地址请求消息，DHCP检测Client是否合法（主要是检测Client的网卡MAC地址），如果合法则返回Client的IP地址，同时将pxe环境下的Boot loader文件pxelinux.0的位置信息传送给Client。
  * Client 向PXE Server上的TFTP请求pxelinux.0，TFTP接收到消息之后再向Client发送pxelinux.0大小信息，试探Client是否满意，当TFTP收到Client发回的同意大小信息之后，正式向Client发送pxelinux.0。
  * Client 执行接收到的pxelinux.0文件。
  * Client 向TFTP请求pxelinux.cfg文件(其实它是目录，里面放置的是是启动菜单，即grub的配置文件)，TFTP将配置文件发回Client，继而Client根据配置文件执行后续操作。
  * Client 向TFTP发送Linux内核请求信息，TFTP接收到消息之后将内核文件发送给Client。
  * Client 向TFTP发送根文件请求信息，TFTP接收到消息之后返回Linux根文件系统。
  * Client 加载Linux内核（启动参数已经在4中的配置文件中设置好了）。
  * Client 通过nfs/ftp/http下载系统安装文件进行安装。如果在4中的配置文件指定了kickstart路径，则会根据此文件自动应答安装系统。

* 基础配置
  * 常用命令:
      | 类型 | 命令 |
      | :- | :-|
      | 线上帮助命令 | man,help |
      | 打包压缩/解压 | tar,zip,unzip,gzip |
      | 文件/目录操作 | cd,cp,find,mkdir/rmdir,mv,pwd,rename,rm,touch,tree,basename,dirname,file,md5sum |
      | 查看文件/内容处理 | cat,tac,more/less,head/tail,cut,split,paste,sort,uniq,wc,iconv,dos2unix,diff,rev,grep/egrep,join,tr |
      | 信息显示 | uname,hostname,dmesg,uptime,stat,du,df,top,free,date,cal |
      | 搜索命令 | which,find,whereis,locate/updatedb |
      | 用户管理 | useradd,usermod,userdel,groupadd,passwd,chage,chattr/lsattr,id,su,visudo,chacl |
      | 基础网络 | telnet,ssh,scp,wget,curl,ping,route,ifconfig,ifup/ifdown,netstat,ss,nc |
      | 深入网络 | nmap,lsof,mail,mutt,nslookup,dig,host,traceroute,tcpdump,sar|
      | 磁盘/文件系统 | mount/umount,fsck,dd,dumpe2fs,dump,fdisk,parted,mkfs,partprobe,e2fsck,mkswap,swapon/swapoff,sync,resize2fs |
      | lvm/raid | lvcreate,lvremove,lvextend,lvreduce,pvcreate,pvremove,pvresize,pvdisplay,vgcreate,vgextend,vgremove,mdadm |
      | 系统权限 | chmod,chown,chgrp,umask,lsattr,chattr |
      | 查看系统登陆 | whoami,who,w,last,lastlog,users,finger |
      | 其他 | echo,printf,rpm,yum,watch,alias/unalias,date,clear,history,eject,xargs,time,exec,export,unset,type,bc |
      | 系统管理及性能监控 | chkconfig,vmstat,mpstat,iostat,sar,ipcs,strace,ltrace |
      | 关机/重启 | shutdown,halt,poweroff,logout,exit, ctrl + d |
      | 进程管理 | bg,fg,jobs,kill,killall,pkill,crontab,ps,pstree,nice/renice,nohup,pgrep,runlevel,init,service |
  * 登陆的相关配置: `/etc/login.defs`

    ```shell
    shell:
        配置文件生效的流程:
        /etc/profile --> /etc/profile.d/*.sh --> ~/.bash_profile --> ~/.bashrc --> /etc/bashrc

    no-shell:
        配置文件生效的流程:
        ~/.bashrc --> /etc/bashrc --> /etc/profile.d/*.sh
    ```

  * PAM 模块(/etc/pam.d/ 下)

    ```文件书写格式
    验证类型    控制标志        引用的模块
    auth       required      pam_securetty.so
    account    requisite     pam_nologin.so
    session    sufficient    pam_selinux.so
    password   optional      pam_console.so
                             pam_loginuid.so
                             pam_env.so
                             pam_unix.so
                             pam_pwquality.so
                             pan_limits.so
    ```

  * Linux 系统启动流程

    ```shell
    启动流程：通常引导程序存放在 硬盘的第一个扇区(64+446+2=512Bytes)
    通电 ---> BIOS ---> MBR(master boot record) ---> GRUB 启动引导 --->
    内核引导 ---> 系统初始化
    ```

  * Linux 网络
    * OSI 七层网络模型 <https://www.cnblogs.com/lemo-/p/6391095.html>
      | OSI 层级 | 各层功能 |
      | :-: | :- |
      | 应用层 | 为应用程序提供服务 |
      | 表示层 | 数据格式转化、数据加密 |
      | 会话层 | 建立、管理和维护会话 |
      | 传输层 | 建立、管理和维护端到端的连接 |
      | 网络层 | IP 选址及路由选择 |
      | 数据链路层 | 提供介质访问和链路管理 |
      | 物理层 | 物理层 |
    * TCP/IP 协议簇
      * TCP协议和UDP协议的区别是什么
        * TCP协议是有连接的，有连接的意思是开始传输实际数据之前TCP的客户端和服务器端必须通过三次握手建立连接，会话结束之后也要结束连接。而UDP是无连接的
        * TCP协议保证数据按序发送，按序到达，提供超时重传来保证可靠性，但是UDP不保证按序到达，甚至不保证到达，只是努力交付，即便是按序发送的序列，也不保证按序送到。
        * TCP协议所需资源多，TCP首部需20个字节（不算可选项），UDP首部字段只需8个字节。
        * TCP有流量控制和拥塞控制，UDP没有，网络拥堵不会影响发送端的发送速率
        * TCP是一对一的连接，而UDP则可以支持一对一，多对多，一对多的通信。
        * TCP面向的是字节流的服务，UDP面向的是报文的服务。
      * IP 地址介绍(A、B、C、D、E 类地址，子网掩码)   <https://blog.csdn.net/qq_35644234/article/details/68951041>
      * TCP 的三次握手和四次挥手    <https://www.cnblogs.com/zmlctt/p/3690998.html>
        > * 所谓三次握手,是指客户端与服务端建立 TCP 连接，需要发送三次数据包
        > * 三次握手的目的是连接服务器指定端口，建立TCP连接,并同步连接双方的序列号和确认号并交换 TCP 窗口大小信息.在socket编程中，客户端执行connect()时。将触发三次握手
      * DNS 解析过程
        > * 浏览器缓存 --> 系统缓存(/etc/hosts文件) --> 路由器缓存 --> ISP(互联网服务提供商) DNS缓存 --> 根域名服务器 --> 顶级域名服务器 --> 保存结果至缓存
        > * 向本地请求查询结构一般为 `递归`, 向根服务器查询为 `迭代`
      * HTTP 协议  <https://www.cnblogs.com/wangning528/p/6388464.html>
        * HTTP 是一个应用层协议(有时基于 SSL 层上),由请求和响应构成
        * HTTP 是无状态的连接
        * HTTP 的工作流程
          * 点击 超链接，触发 客户端与 服务端的 socket 建立
          * 连接建立后，client 发生请求给服务端，请求格式: 统一资源标识符、协议版本号、MIME信息体(请求修饰符、客户机信息、可能的内容)
          * 服务端接到请求后，发送相应的响应信息: 其格式为一个状态行，包括信息的协议版本号、一个成功或错误的代码，后边是MIME信息包括服务器信息、实体信息和可能的内容。
          * 客户端将接收到的信息在 浏览器上解析显示
  * 在 centos 下 的网络配置和故障诊断流程
    * 诊断流程使用命令

      ```shell
      lspci 和 dmesg              查看 网卡驱动是否正常
      ethtool [DEVICENAME]        查看相应网卡的设备信息

      安装相应的 命令软件
      yum install -y bind-utils traceroute net-tools

      ifconfig [DEVICENAME] /  ip --help
      ping -c 2 127.0.0.1
      ping -c 5 [Gateway address]
      ping -c 5 [Route Address]
      route -n
      traceroute -I [IP Address]
      dig www.baidu.com
      nslookup www.baidu.com
      ```

  * 基础配置文件

    ```shell
    /etc/hosts           主机名 和 IP 地址的对应关系，可用于 DNS 的初步解析
    /etc/resolv.conf     该主机的 DNS 配置显示内容，一般是生成的
    /etc/sysconfig/network  该主机的网卡是否受 network-manager 管理
    /etc/sysconfig/network-scripts/ifcfg-ethN       该主机的网络参数配置文件(包括:开机自启动、启动后获取协议:static|none|dhcp、IPADDRESS、DNS、GATEWAY、NETMASK 等参数)
    /etc/hosts.allow  /etc/hosts.deny               用于配置主机那些 IP 准入/拒绝
    ```

  * 常用的 Linux 主机安全防护
    * 禁止 Ctrl+Alt+Del 直接重启服务器
      `/bin/mv /etc/init/control-alt-delete.conf /etc/init/control-alt-delete.conf.bak`
    * 使用强密码

      ```shell
      密码不得少于8位，并且需要同时包含大、小字母，数字和特殊字符；避免使用常见的单词。
      设置：
          sed -i "s/password requisite pam_cracklib.so.*/password required pam_cracklib.so try_first_pass retry=6 minlen=8 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1 enforce_for_root/g" /etc/pam.d/system-auth
      ```

    * 连续6次输错密码禁用一段时间，设置为300秒

      ```shell
      sed -i "/#%PAM-1.0/a\auth required pam_tally2.so onerr=fail deny=6 unlock_time=300 even_deny_root root_unlock_time=300" /etc/pam.d/system-auth
      ```

    * 记录用户上次登录时间
      `echo "LASTLOG_ENAB yes" >>/etc/login.defs`
    * 设置空闲时间和history配置

      ```shell
      echo "export TMOUT=600" >>/etc/profile
      echo "export HISTFILESIZE=5000" >>/etc/profile
      source /etc/profile
      echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> /etc/bashrc
      source /etc/bashrc
      ```

    * SSH服务安全策略
      * 禁止使用root账户通过SSH方式登录；
        `echo "PermitRootLogin no" >>/etc/ssh/sshd_config`

      * 修改SSH服务的空闲等待时间
        `echo "ClientAliveInterval 300" >>/etc/ssh/sshd_config`

      * 设置SSH连接尝试次数
        `echo "MaxAuthTries 3" >>/etc/ssh/sshd_config`
         修改完以后需要重新启动SSH服务生效
         `service sshd restart`

    * 针对不同的应用服务，设置相应的 用户，并设置恰当的权限
    * 删除不用的 用户组和用户
    * 关闭不用的系统服务、开启防火墙，并只开放相应端口
  * 内核参数调整(/etc/security/limits.conf)   <https://blog.csdn.net/mengzhisuoliu/article/details/49644533>

    ```shell
    # Kernel sysctl configuration file for Red Hat Linux
    # For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and 对于二进制值而言,0表示禁用,1表示启用,更多详细的信息可以查看第五到第八行的信息
    # sysctl.conf(5) for more details.
    # Controls IP packet forwarding     控制IP包转发
    net.ipv4.ip_forward = 0

    # Controls source route verification    控制源路由校验
    net.ipv4.conf.default.rp_filter = 1

    # Do not accept source routing  是否允许源地址经过路由
    net.ipv4.conf.default.accept_source_route = 0

    # Controls the System Request debugging functionality of the kernel
    # 内核系统请求调试功能控制,0表示禁用,1表示启用
    kernel.sysrq = 0

    # Controls whether core dumps will append the PID to the core filename.
    # 内核转存是否根据进程ID保存成文件

    # Useful for debugging multi-threaded applications.
    # 这有利于多线程调试,0表示禁用,1表示启用
    kernel.core_uses_pid = 1

    # Controls the use of TCP syncookies
    # 是否使用TCP同步cookies,0表示禁用,1表示启用
    net.ipv4.tcp_syncookies = 1

    # Disable netfilter on bridges.
    # 禁用桥接网络过滤,0表示禁用,1表示启用
    net.bridge.bridge-nf-call-ip6tables = 0
    net.bridge.bridge-nf-call-iptables = 0
    net.bridge.bridge-nf-call-arptables = 0

    # Controls the default maxmimum size of a mesage queue
    # 消息队列最大值
    kernel.msgmnb = 65536

    # Controls the maximum size of a message, in bytes
    # 设置消息的大小,以字节为单位
    kernel.msgmax = 65536

    # Controls the maximum shared segment size, in bytes
    # 控制最大的共享段最大使用尺寸,以字节为单位,对于oracle来说，通常将其设置为2G。
    kernel.shmmax = 4294967295

    # Controls the maximum number of shared memory segments, in pages
    # 控制最大页面内最大的共享内存段,该参数表示系统一次可以使用的共享内存总量（以页为单位）,通常不需要修改。
    kernel.shmall = 268435456  

    #########以下是自定义增加的
    #这个内核参数用于设置系统范围内共享内存段的最大数量。该参数的默认值是 4096 。通常不需要更改。
    kernel.shmmni= 4096

    #该参数表示可以使用的信号量
    kernel.sem = 5010 641280 5010 128

    #该参数表示可以使用的文件句柄最大数量,也就是可以打开最多的文件数量
    fs.file-max=65536

    #0表示禁用,1表示启用,表示开启SYN Cookies,当SYN等待队列溢出时,启用cookies来处理,可以防范少量的SYN攻击,默认为0,表示关闭
    net.ipv4.tcp_syncookies = 1

    #0表示禁用,1表示启用,允许将TIME_WAIT sockets重新用于新的TCP连接,默认为0,表示关闭
    net.ipv4.tcp_tw_reuse = 1

    #0表示禁用,1表示启用,允许将TIME_WAIT sockets快速回收以便利用,默认为0,表示关闭
    net.ipv4.tcp_tw_recycle = 1

    #设置TCP三次请求的fin状态超时
    net.ipv4.tcp_fin_timeout = 30

    #以上4个绿色的设置,以防DDoS,CC和SYN攻击

    #下面几个提升服务器的并发能力,设置之后可以将TPC/IP并发能力提高

    #设置TCP 发送keepalive的频度,默认的缺省为2小时,1200秒表示20分钟,表示服务器以20分钟发送keepalive消息
    net.ipv4.tcp_keepalive_time = 1200

    #探测包发送的时间间隔设置为2秒
    net.ipv4.tcp_keepalive_intvl = 2

    #如果对方不给予应答,探测包发送的次数
    net.ipv4.tcp_keepalive_probes = 2

    #设置本地端口范围,缺省情况下:32768 到 61000,现在改为10000 到 65000,最小值不能设置太低,否则占用了正常端口
    net.ipv4.ip_local_port_range = 10000 65000

    #表示SYN队列的长度,默认为1024,加大队列长度为8192,可以容纳更多的网络连接数
    net.ipv4.tcp_max_syn_backlog = 8192

    #设置保持TIME_WAIT的最大数量,如果超过这个数量,TIME_WAIT将立刻清楚并打印警告信息,默认为180000,改为5000.对于Apache,Nginx等服务器,上几行的参数可以很好滴减少TIME_WAIT套接字数量,对于Squid(代理软件,实现正向代理或者反向代理,主要以实现缓存为主),效果却不打.此项参数可以控制TIME_WAIT的最大数量,避免Squid服务器被大量的TIME_WAIT拖死.
    net.ipv4.tcp_max_tw_buckets = 5000

    #配置服务器拒绝接受广播风暴或者smurf 攻击attacks,0表示禁用,1表示启用,这是忽略广播包的作用
    net.ipv4.icmp_echo_ignore_broadcasts = 1

    #有些路由器针对广播祯发送无效的回应，每个都产生警告并在内核产生日志。这些回应可以被忽略,0表示禁用,1表示启用,
    net.ipv4.icmp_ignore_bogus_error_responses = 1

    #开启并记录欺骗，源路由和重定向包
    net.ipv4.conf.all.log_martians = 1

    #表示SYN队列的长度，选项为服务器端用于记录那些尚未收到客户端确认信息的连接请求的最大值。
    # 该参数对应系统路径为：/proc/sys/net/ipv4/tcp_max_syn_backlog
    net.ipv4.tcp_max_syn_backlog = 4096

    #增加tcp buff  size,tcp_rmem表示接受数据缓冲区范围从4096 到 87380 到16777216
    net.ipv4.tcp_rmem = 4096 87380 16777216
    net.ipv4.tcp_wmem = 4096 65536 16777216

    #TCP失败重传次数,默认值15,意味着重传15次才彻底放弃.可减少到5,以尽早释放内核资源
    net.ipv4.tcp_retries2 = 5

    #选项默认值是128，这个参数用于调节系统同时发起的tcp连接数，在高并发请求中，默认的值可能会导致连接超时或重传，因此，需要结合并发请求数来调节此值。该参数对应系统路径为：/proc/sys/net/core/somaxconn 128
    net.core.somaxconn = 4096

    #设置tcp确认超时时间 300秒,这在TCP三次握手有体现,结合本文的图理解
    net.netfilter.nf_conntrack_tcp_timeout_established = 300

    #设置tcp等待时间 12秒,超过12秒自动放弃
    net.netfilter.nf_conntrack_tcp_timeout_time_wait = 12

    #设置tcp关闭等待时间60秒,超过60秒自动关闭
    net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60

    #设置tcp fin状态的超时时间为120秒,超过该时间自动关闭
    net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
    ```

  * shell 编程 和 正则表达式
  * 基础服务的安装
  * iptables 的使用 <https://blog.csdn.net/u010472499/article/details/78292811>

DevOps
------

* ansible 应用部署，配置分发，流程编排
  * 安装
    `yum install ansible`
  * ansible 效率提升配置
    * 开启 ssh 长连接:
      > OpenSSH 的版本在 5.6 之后，提供了 `Multiplexing` 特性。可在 ansible.cfg 中配置 `sh_args = -o ControlMaster=auto -o ControlPersist=5d`
    * 开启 pipelining, 是 OpenSSH 的特性
      > ansible 的执行流程中有一个是将本地生成好的 python 脚本文件 put 到远端服务器，当开启 pipelining 时，该过程则在 ssh 会话中进行。
      > 开启 pipelining，需要被控制机 `/etc/sudoers` 文件中对于当前的 ansible ssh 用户配置 `requiretty` 属性。
      > ansible.cfg 配置文件中 `pipelining= True`
    * 开启 accelerate 模式
      > 在中控机和被控机上安装 `python-keyczar` 软件包, 然后在 playbook 中配置 `accelerate: true`,
      > 在 ansible.cfg 中配置

        ```conf
        [accelerate]
        accelerate_port = 5099
        accelerate_timeout = 30
        accelerate_connect_timeout = 10
        ```

    * 设置 facts 缓存

      ```conf
      gathering = smart
      fact_caching_timeout = 86400
      fact_caching = jsonfile
      fact_caching_connection = /dev/shm/ansible_fact_cache
      ```

  * playbook 的编写
    * 模块

      ```shell
      核心模块: paramiko,pyyaml
      扩展模块: setup,user,group,stat,fail,unarchive,file,copy,template,service,shell,command,script,
      自定义模块: 插件开发、日志记录、邮件发送等模块
      ```

    * 变量调用顺序
      * command line value(eg "-u user")
      * role defaults
      * inventory file or script group vars
      * inventory group_vars/all
      * playbook group_vars/all
      * inventory group_vars/*
      * playbook group_vars/*
      * inventory file or script host vars
      * inventory host_vars/*
      * playbook host_vars/*
      * host facts / cached set_facts
      * play vars
      * play vars_prompt
      * play vars_files
      * role vars(defined in role /vars/main.yaml)
      * block vars(only for tasks in block)
      * task vars(only for the task)
      * include_vars
      * set_facts / registered vars
      * role (and include_role) params
      * include params
      * extra vars(always win precedence)

    * 编写和调试
      `ansible-playbook site.yaml --syntax-check`
    * ansible 的架构
      * ![avatar](pictures/ansible_architecture.png)
      * ![avatar](pictures/ansible_principle.png)
* git 版本管理   <https://www.cnblogs.com/zhaoyanjun/p/5073818.html>
  * 分支策略
    * 主分支 master
    * 开发分支 develop
    * 功能分支 feature
    * 预发布分支  release
    * bug 分支 hotfix
  * git 基础概念
  * 常用命令
* 自动化构建 Jenkins
* ITIL

Common Service
--------------

* HAProxy 中间件
  * Haproxy,LVS,nginx 的对比
    ![avatar](pictures/haproxy_nginx_lvs_apache_compare1.png)
    ![avatar](pictures/haproxy_nginx_lvs_apache_compare2.png)

  * haproxy 的简介 <http://www.cnblogs.com/kevingrace/p/6138150.html>
    > HAProxy是法国人Willy Tarreau开发的一款可应对客户端10000以上的同时连接的高性能的TCP和HTTP负载均衡器。由于其丰富强大的功能在国内备受推崇，是目前主流的负载均衡器。Haproxy是一个开源的高性能的反向代理或者说是负载均衡服务软件之一，它支持双机热备、虚拟主机、基于TCP和HTTP应用代理等功能。其配置简单，而且拥有很好的对服务器节点的健康检查功能（相当于keepalived健康检查），当其代理的后端服务器出现故障时，Ｈaproxy会自动的将该故障服务器摘除，当服务器的故障恢复后haproxy还会自动重新添加回服务器主机。
    > Haproxy实现了一种事件驱动、单一进程模型，此模型支持非常大的并发连接数。多进程或多线程模型受内存限制、系统调度器限制以及无处不在的锁限制，很少能处理数千并发连接。事件驱动模型因为在有更好的资源和时间管理的用户空间(User-Space)实现所有这些任务，所以没有这些问题。此模型的弊端是，在多核系统上，这些程序通常扩展性较差。这就是为什么必须对其进行优化以使每个CPU时间片(Cycle)做更多的工作。
    > Haproxy特别适用于那些负载特大的web站点，这些站点通常又需要会话保持或七层处理。haproxy运行在当前的硬件上，完全可以支持数以万计的并发连接。并且它的运行模式使得它可以很简单安全的整合进当前架构中，同时可以保护web服务器不被暴露到网络上。
    > Haproxy软件引入了frontend，backend的功能，frontend（acl规则匹配）可以根据任意HTTP请求头做规则匹配，然后把请求定向到相关的backend（server pools等待前端把请求转过来的服务器组）。通过frontend和backend，可以很容易的实现Haproxy的7层负载均衡代理功能。
    > Haproxy是一种高效、可靠、免费的高可用及负载均衡解决方案，非常适合于高负载站点的七层数据请求。客户端通过Haproxy代理服务器获得站点页面，而代理服务器收到客户请求后根据负载均衡的规则将请求数据转发给后端真实服务器。
* MySQL 数据库 <https://www.mysql.com/cn/why-mysql/performance/index.html>
  * mysql 的主从复制原理: `master:log dump 线程，向 slave 的IO 线程传binglog, slave 的 IO 线程读取 binlog 后生成 relay log 中继日志，再交由 sql 线程回写到库中`
  * mysql 对 主从复制的效率提升和缺陷修复: 半同步复制和并行复制(`set global slave_parallel_workers=10;`)
  * my.cnf 配置文件的解析

    ```conf
    [client]
    port                      = 3306
    socket                    = /lvm_extend_partition/qos/mysql-5.7.24/running_info/mysql.sock
    default-character-set     = utf8mb4
    #mysqlde utf8字符集默认为3位的，不支持emoji表情及部分不常见的汉字，故推荐使用utf8mb4

    [mysql]
    default-character-set     = utf8mb4

    [mysqld]
    skip-locking              #避免MySQL的外部锁定，减少出错几率增强稳定性。

    # 禁止MySQL对外部连接进行DNS解析，使用这一选项可以消除MySQL进行DNS解析的时间。但需要注意，如果开启该选项，则所有远程主机连接授权都要使用IP地址方式，否则MySQL将无法正常处理连接请求！
    #skip-name-resolve

    back_log = 512
    # MySQL能有的连接数量。当主要MySQL线程在一个很短时间内得到非常多的连接请求，这就起作用，
    # 然后主线程花些时间(尽管很短)检查连接并且启动一个新线程。back_log值指出在MySQL暂时停止回答新请求之前的短时间内多少个请求可以被存在堆栈中。
    # 如果期望在一个短时间内有很多连接，你需要增加它。也就是说，如果MySQL的连接数据达到max_connections时，新来的请求将会被存在堆栈中，
    # 以等待某一连接释放资源，该堆栈的数量即back_log，如果等待连接的数量超过back_log，将不被授予连接资源。
    # 另外，这值（back_log）限于您的操作系统对到来的TCP/IP连接的侦听队列的大小。
    # 你的操作系统在这个队列大小上有它自己的限制（可以检查你的OS文档找出这个变量的最大值），试图设定back_log高于你的操作系统的限制将是无效的。默认值为50，对于Linux系统推荐设置为小于512的整数。

    key_buffer_size = 64M
    # 这是mysql优化中非常重要的一项配置
    # 指定用于索引的缓冲区大小，增加它可得到更好处理的索引(对所有读和多重写)。注意：该参数值设置的过大反而会是服务器整体效率降低
    # 默认值是16M，对于内存在4GB左右的服务器该参数可设置为384M或512M。
    # 想要知道key_buffer_size设置是否合理，通过命令show global status like 'key_read%';来查看Key_read_requests（索引请求次数）和Key_reads（从i/o中读取数据，也就是未命中索引），
    # 计算索引未命中缓存的概率：key_cache_miss_rate = Key_reads / Key_read_requests * 100%，至少是1:100，1:1000更好，比如我的key_cache_miss_rate = 15754 / 26831941 * 100% = 1/1700，也就是说1700个中只有一个请求直接读取硬盘
    # 如果key_cache_miss_rate在0.01%以下的话，key_buffer_size分配的过多，可以适当减少。
    # MySQL服务器还提供了key_blocks_*参数：show global status like 'key_blocks_u%';
    # Key_blocks_unused表示未使用的缓存簇(blocks)数，Key_blocks_used表示曾经用到的最大的blocks数，比如这台服务器，所有的缓存都用到了，要么增加key_buffer_size，要么就是过渡索引了，把缓存占满了。
    # 比较理想的设置：Key_blocks_used / (Key_blocks_unused + Key_blocks_used) * 100% < 80%
    max_connections = 1500
    # MySQL的最大连接数，默认是100，测试开过1万个连接数，并将他们持久化，内存增加了一个多G，由此算出一个连接大概为100+K。
    # 如果服务器的并发连接请求量比较大，建议调高此值，以增加并行连接数量，当然这建立在机器能支撑的情况下，因为如果连接数越多，介于MySQL会为每个连接提供连接缓冲区，就会开销越多的内存，所以要适当调整该值，不能盲目提高设值。可以过'conn%'通配符查看当前状态的连接数量，以定夺该值的大小。
    # 比较理想的设置应该是max_used_connections / max_connections * 100% ≈ 80%，当发现这一比例在10%以下的话，说明最大连接数设置的过高了
    # 查看最大的连接数：SHOW VARIABLES LIKE "max_connections";
    # 查看已使用的最大连接：SHOW GLOBAL STATUS LIKE 'max_used_connections';
    # 显示连接相关的设置：SHOW STATUS LIKE '%connect%';
    # 显示当前正在执行的mysql连接：SHOW PROCESSLIST
    innodb_buffer_pool_size = 128M
    # InnoDB使用一个缓冲池来保存索引和原始数据, 默认值为128M。
    # 这里你设置越大,你在存取表里面数据时所需要的磁盘I/O越少.
    # 在一个独立使用的数据库服务器上,你可以设置这个变量到服务器物理内存大小的80%即5-6GB(8GB内存)，20-25GB(32GB内存)，100-120GB(128GB内存)，注意这是在独立数据库服务器中推荐的设置
    # 不要设置过大,否则,会导致system的swap空间被占用，导致操作系统变慢，从而减低sql查询的效率。
    # 注意在32位系统上你每个进程可能被限制在 2-3.5G 用户层面内存限制,所以不要设置的太高.
    query_cache_size = 0
    # MySQL的查询缓冲大小（从4.0.1开始，MySQL提供了查询缓冲机制）使用查询缓冲，MySQL 5.6以后的默认值为0，MySQL将SELECT语句和查询结果存放在缓冲区中，
    # query cache（查询缓存）是一个众所周知的瓶颈，甚至在并发并不多的时候也是如此。 最佳选项是将其从一开始就停用，设置query_cache_size = 0（MySQL 5.6以后的默认值）并利用其他方法加速查询：优化索引、增加拷贝分散负载或者启用额外的缓存（比如memcache或redis）。
    # 打开query cache（Qcache）对读和写都会带来额外的消耗：a、读查询开始之前必须检查是否命中缓存。b、如果读查询可以缓存，那么执行完之后会写入缓存。 c、当向某个表写入数据的时候，必须将这个表所有的缓存设置为失效
    # 缓存存放在一个引用表中，通过一个哈希值引用，这个哈希值包括查询本身，数据库，客户端协议的版本等，任何字符上的不同，例如空格，注释都会导致缓存不命中。
    # 通过命令：show status like '%query_cache%';查看查询缓存相关设置:
    # have_query_cache：是否有此功能
    # query_cache_limit：允许 Cache 的单条 Query 结果集的最大容量，默认是1MB，超过此参数设置的 Query 结果集将不会被 Cache
    # query_cache_min_res_unit：设置 Query Cache 中每次分配内存的最小空间大小，也就是每个 Query 的 Cache 最小占用的内存空间大小
    # uery_cache_size：设置 Query Cache 所使用的内存大小，默认值为0，大小必须是1024的整数倍，如果不是整数倍，MySQL 会自动调整降低最小量以达到1024的倍数
    # query_cache_type：控制 Query Cache 功能的开关，可以设置为0(OFF),1(ON)和2(DEMAND)三种，意义分别如下：
    # # 0(OFF)：关闭 Query Cache 功能，任何情况下都不会使用 Query Cache
    # # 1(ON)：开启 Query Cache 功能，但是当 SELECT 语句中使用的 SQL_NO_CACHE 提示后，将不使用Query Cache
    # # 2(DEMAND)：开启 Query Cache 功能，但是只有当 SELECT 语句中使用了 SQL_CACHE 提示后，才使用 Query Cache
    # query_cache_wlock_invalidate：控制当有写锁定发生在表上的时刻是否先失效该表相关的 Query Cache，如果设置为 1(TRUE)，则在写锁定的同时将失效该表相关的所有 Query Cache，如果设置为0(FALSE)则在锁定时刻仍然允许读取该表相关的 Query Cache。
    # 通过命令：show status like ‘%Qcache%’;查看查询缓存使用状态值:
    # Qcache_free_blocks：目前还处于空闲状态的 Query Cache 中内存 Block 数目
    # Qcache_free_memory：目前还处于空闲状态的 Query Cache 内存总量
    # Qcache_hits：Query Cache 命中次数
    # Qcache_inserts：向 Query Cache 中插入新的 Query Cache 的次数，也就是没有命中的次数
    # Qcache_lowmem_prunes：当 Query Cache 内存容量不够，需要从中删除老的 Query Cache 以给新的 Cache 对象使用的次数
    # Qcache_not_cached：没有被 Cache 的 SQL 数，包括无法被 Cache 的 SQL 以及由于 query_cache_type 设置的不会被 Cache 的 SQL
    # Qcache_queries_in_cache：目前在 Query Cache 中的 SQL 数量
    # Qcache_total_blocks：Query Cache 中总的 Block 数量  
    # 如果Qcache_hits的值也非常大，则表明查询缓冲使用非常频繁，且Qcache_free_memory值很小，此时需要增加缓冲大小；
    # 如果Qcache_hits的值不大，且Qcache_free_memory值较大，则表明你的查询重复率很低，查询缓存不适合你当前系统，这种情况下使用查询缓冲反而会影响效率，可以通过设置query_cache_size = 0或者query_cache_type 来关闭查询缓存。
    # Query Cache 的大小设置超过256MB，这也是业界比较常用的做法。此外，在SELECT语句中加入SQL_NO_CACHE可以明确表示不使用查询缓冲
    max_connect_errors = 6000
    # 对于同一主机，如果有超出该参数值个数的中断错误连接，则该主机将被禁止连接。如需对该主机进行解禁，执行：FLUSH HOST。防止黑客  
    open_files_limit = 65535
    # MySQL打开的文件描述符限制，默认最小1024;当open_files_limit没有被配置的时候，比较max_connections*5和ulimit -n的值，哪个大用哪个，
    # 当open_file_limit被配置的时候，比较open_files_limit和max_connections*5的值，哪个大用哪个。
    table_open_cache = 128
    # MySQL每打开一个表，都会读入一些数据到table_open_cache缓存中，当MySQL在这个缓存中找不到相应信息时，才会去磁盘上读取。默认值64
    # 假定系统有200个并发连接，则需将此参数设置为200*N(N为每个连接所需的文件描述符数目)；
    # 当把table_open_cache设置为很大时，如果系统处理不了那么多文件描述符，那么就会出现客户端失效，连接不上
    max_allowed_packet = 4M
    # 接受的数据包大小；增加该变量的值十分安全，这是因为仅当需要时才会分配额外内存。例如，仅当你发出长查询或MySQLd必须返回大的结果行时MySQLd才会分配更多内存。
    # 该变量之所以取较小默认值是一种预防措施，以捕获客户端和服务器之间的错误信息包，并确保不会因偶然使用大的信息包而导致内存溢出。
    binlog_cache_size = 1M
    # 一个事务，在没有提交的时候，产生的日志，记录到Cache中；等到事务提交需要提交的时候，则把日志持久化到磁盘。默认binlog_cache_size大小32K
    max_heap_table_size = 8M
    # 定义了用户可以创建的内存表(memory table)的大小。这个值用来计算内存表的最大行数值。这个变量支持动态改变
    tmp_table_size = 16M
    # MySQL的heap（堆积）表缓冲大小。所有联合在一个DML指令内完成，并且大多数联合甚至可以不用临时表即可以完成。
    # 大多数临时表是基于内存的(HEAP)表。具有大的记录长度的临时表 (所有列的长度的和)或包含BLOB列的表存储在硬盘上。
    # 如果某个内部heap（堆积）表大小超过tmp_table_size，MySQL可以根据需要自动将内存中的heap表改为基于硬盘的MyISAM表。还可以通过设置tmp_table_size选项来增加临时表的大小。也就是说，如果调高该值，MySQL同时将增加heap表的大小，可达到提高联接查询速度的效果
    read_buffer_size = 2M
    # MySQL读入缓冲区大小。对表进行顺序扫描的请求将分配一个读入缓冲区，MySQL会为它分配一段内存缓冲区。read_buffer_size变量控制这一缓冲区的大小。
    # 如果对表的顺序扫描请求非常频繁，并且你认为频繁扫描进行得太慢，可以通过增加该变量值以及内存缓冲区大小提高其性能
    read_rnd_buffer_size = 8M
    # MySQL的随机读缓冲区大小。当按任意顺序读取行时(例如，按照排序顺序)，将分配一个随机读缓存区。进行排序查询时，
    # MySQL会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度，如果需要排序大量数据，可适当调高该值。但MySQL会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存开销过大
    sort_buffer_size = 8M
    # MySQL执行排序使用的缓冲大小。如果想要增加ORDER BY的速度，首先看是否可以让MySQL使用索引而不是额外的排序阶段。
    # 如果不能，可以尝试增加sort_buffer_size变量的大小
    join_buffer_size = 8M
    # 联合查询操作所能使用的缓冲区大小，和sort_buffer_size一样，该参数对应的分配内存也是每连接独享
    thread_cache_size = 8
    # 这个值（默认8）表示可以重新利用保存在缓存中线程的数量，当断开连接时如果缓存中还有空间，那么客户端的线程将被放到缓存中，
    # 如果线程重新被请求，那么请求将从缓存中读取,如果缓存中是空的或者是新的请求，那么这个线程将被重新创建,如果有很多新的线程，
    # 增加这个值可以改善系统性能.通过比较Connections和Threads_created状态的变量，可以看到这个变量的作用。(–>表示要调整的值)
    # 根据物理内存设置规则如下：
    # 1G  —> 8
    # 2G  —> 16
    # 3G  —> 32
    # 大于3G  —> 64

    query_cache_limit = 2M
    #指定单个查询能够使用的缓冲区大小，默认1M

    ft_min_word_len = 4
    # 分词词汇最小长度，默认4

    transaction_isolation = REPEATABLE-READ
    # MySQL支持4种事务隔离级别，他们分别是：
    # READ-UNCOMMITTED, READ-COMMITTED, REPEATABLE-READ, SERIALIZABLE.
    # 如没有指定，MySQL默认采用的是REPEATABLE-READ，ORACLE默认的是READ-COMMITTED

    log_bin = mysql-bin
    binlog_format = mixed
    expire_logs_days = 30 #超过30天的binlog删除

    log_error = /lvm_extend_partition/qos/mysql-5.7.24/logs/mysql-error.log #错误日志路径
    slow_query_log = 1
    long_query_time = 1 #慢查询时间 超过1秒则为慢查询
    slow_query_log_file = /lvm_extend_partition/qos/mysql-5.7.24/logs/mysql-slow.log

    performance_schema = 0
    explicit_defaults_for_timestamp

    #lower_case_table_names = 1 #不区分大小写

    skip-external-locking #MySQL选项以避免外部锁定。该选项默认开启

    default-storage-engine = InnoDB #默认存储引擎

    innodb_file_per_table = 1
    # InnoDB为独立表空间模式，每个数据库的每个表都会生成一个数据空间
    # 独立表空间优点：
    # 1．每个表都有自已独立的表空间。
    # 2．每个表的数据和索引都会存在自已的表空间中。
    # 3．可以实现单表在不同的数据库中移动。
    # 4．空间可以回收（除drop table操作处，表空不能自已回收）
    # 缺点：
    # 单表增加过大，如超过100G
    # 结论：
    # 共享表空间在Insert操作上少有优势。其它都没独立表空间表现好。当启用独立表空间时，请合理调整：innodb_open_files

    innodb_open_files = 500
    # 限制Innodb能打开的表的数据，如果库里的表特别多的情况，请增加这个。这个值默认是300

    innodb_write_io_threads = 4
    innodb_read_io_threads = 4
    # innodb使用后台线程处理数据页上的读写 I/O(输入输出)请求,根据你的 CPU 核数来更改,默认是4
    # 注:这两个参数不支持动态改变,需要把该参数加入到my.cnf里，修改完后重启MySQL服务,允许值的范围从 1-64

    innodb_thread_concurrency = 0
    # 默认设置为 0,表示不限制并发数，这里推荐设置为0，更好去发挥CPU多核处理能力，提高并发量

    innodb_purge_threads = 1
    # InnoDB中的清除操作是一类定期回收无用数据的操作。在之前的几个版本中，清除操作是主线程的一部分，这意味着运行时它可能会堵塞其它的数据库操作。
    # 从MySQL5.5.X版本开始，该操作运行于独立的线程中,并支持更多的并发数。用户可通过设置innodb_purge_threads配置参数来选择清除操作是否使用单
    # 独线程,默认情况下参数设置为0(不使用单独线程),设置为 1 时表示使用单独的清除线程。建议为1

    innodb_flush_log_at_trx_commit = 2
    # 0：如果innodb_flush_log_at_trx_commit的值为0,log buffer每秒就会被刷写日志文件到磁盘，提交事务的时候不做任何操作（执行是由mysql的master thread线程来执行的。
    # 主线程中每秒会将重做日志缓冲写入磁盘的重做日志文件(REDO LOG)中。不论事务是否已经提交）默认的日志文件是ib_logfile0,ib_logfile1
    # 1：当设为默认值1的时候，每次提交事务的时候，都会将log buffer刷写到日志。
    # 2：如果设为2,每次提交事务都会写日志，但并不会执行刷的操作。每秒定时会刷到日志文件。要注意的是，并不能保证100%每秒一定都会刷到磁盘，这要取决于进程的调度。
    # 每次事务提交的时候将数据写入事务日志，而这里的写入仅是调用了文件系统的写入操作，而文件系统是有 缓存的，所以这个写入并不能保证数据已经写入到物理磁盘
    # 默认值1是为了保证完整的ACID。当然，你可以将这个配置项设为1以外的值来换取更高的性能，但是在系统崩溃的时候，你将会丢失1秒的数据。
    # 设为0的话，mysqld进程崩溃的时候，就会丢失最后1秒的事务。设为2,只有在操作系统崩溃或者断电的时候才会丢失最后1秒的数据。InnoDB在做恢复的时候会忽略这个值。
    # 总结
    # 设为1当然是最安全的，但性能页是最差的（相对其他两个参数而言，但不是不能接受）。如果对数据一致性和完整性要求不高，完全可以设为2，如果只最求性能，例如高并发写的日志服务器，设为0来获得更高性能

    innodb_log_buffer_size = 4M
    # 此参数确定些日志文件所用的内存大小，以M为单位。缓冲区更大能提高性能，但意外的故障将会丢失数据。MySQL开发人员建议设置为1－8M之间

    innodb_log_file_size = 32M
    # 此参数确定数据日志文件的大小，更大的设置可以提高性能，但也会增加恢复故障数据库所需的时间

    innodb_log_files_in_group = 3
    # 为提高性能，MySQL可以以循环方式将日志文件写到多个文件。推荐设置为3

    innodb_max_dirty_pages_pct = 90
    # innodb主线程刷新缓存池中的数据，使脏数据比例小于90%

    innodb_lock_wait_timeout = 120
    # InnoDB事务在被回滚之前可以等待一个锁定的超时秒数。InnoDB在它自己的锁定表中自动检测事务死锁并且回滚事务。InnoDB用LOCK TABLES语句注意到锁定设置。默认值是50秒

    bulk_insert_buffer_size = 8M
    # 批量插入缓存大小， 这个参数是针对MyISAM存储引擎来说的。适用于在一次性插入100-1000+条记录时， 提高效率。默认值是8M。可以针对数据量的大小，翻倍增加。

    myisam_sort_buffer_size = 8M
    # MyISAM设置恢复表之时使用的缓冲区的尺寸，当在REPAIR TABLE或用CREATE INDEX创建索引或ALTER TABLE过程中排序 MyISAM索引分配的缓冲区

    myisam_max_sort_file_size = 10G
    # 如果临时文件会变得超过索引，不要使用快速排序索引方法来创建一个索引。注释：这个参数以字节的形式给出

    myisam_repair_threads = 1
    # 如果该值大于1，在Repair by sorting过程中并行创建MyISAM表索引(每个索引在自己的线程内)

    interactive_timeout = 28800
    # 服务器关闭交互式连接前等待活动的秒数。交互式客户端定义为在mysql_real_connect()中使用CLIENT_INTERACTIVE选项的客户端。默认值：28800秒（8小时）

    wait_timeout = 28800
    # 服务器关闭非交互连接之前等待活动的秒数。在线程启动时，根据全局wait_timeout值或全局interactive_timeout值初始化会话wait_timeout值，
    # 取决于客户端类型(由mysql_real_connect()的连接选项CLIENT_INTERACTIVE定义)。参数默认值：28800秒（8小时）
    # MySQL服务器所支持的最大连接数是有上限的，因为每个连接的建立都会消耗内存，因此我们希望客户端在连接到MySQL Server处理完相应的操作后，
    # 应该断开连接并释放占用的内存。如果你的MySQL Server有大量的闲置连接，他们不仅会白白消耗内存，而且如果连接一直在累加而不断开，
    # 最终肯定会达到MySQL Server的连接上限数，这会报'too many connections'的错误。对于wait_timeout的值设定，应该根据系统的运行情况来判断。
    # 在系统运行一段时间后，可以通过show processlist命令查看当前系统的连接状态，如果发现有大量的sleep状态的连接进程，则说明该参数设置的过大，
    # 可以进行适当的调整小些。要同时设置interactive_timeout和wait_timeout才会生效。

    [mysqldump]
    quick
    max_allowed_packet = 16M #服务器发送和接受的最大包长度

    [myisamchk]
    key_buffer_size = 8M
    sort_buffer_size = 8M
    read_buffer = 4M
    write_buffer = 4M
    ```

  * mysql 主从延迟的诊断流程 (version: mysql 5.7)
    * 检查网络: 带宽不足、网络延迟过大等  ---> 如果有网络监控工具: smokeping
    * 性能工具检测机器性能: iostat、sar、vmstat、htop
      * `yum install sysstat-10.1.5-17.el7.x86_64`
      * 从机的硬件配置
      * 从机的负载过高
      * 从机的硬盘是否是高性能读写的 SSD
        * 调度规则: `cat /sys/block/vda/queue/scheduler`
    * 大事务的影响(未执行 commit): `show processlist` 和 `mysqlbinlog 还原 binlog 成 SQL 语句`
    * 锁冲突: `show processlist` 和 查看 `information_scheme 下面和锁以及事务相关的表记录`
    * 参数调整(注意对业务的影响): `innodb_flush_log_at_trx_commit`,`sync_binlog` 或 `tokudb_commit_sync`,`tokudb_fsync_log_period`,`sync_binlog`
    * 多线程(5.5 版本后):
      * 查看是否开启多线程

        ```mysql
        > show processlist;
        > show variables like '%slave_parallel%';
        > STOP SLAVE SQL_THREAD;
        > SET GLOBAL slave_parallel_type='LOGICAL_CLOCK';
        > SET GLOVAL slave_parallel_workers=8;
        > START SLAVE SQL_THREAD;
        ```

      * 统计 slave 机器的相关性能统计 (出于性能考虑，默认是关闭)

        ```mysql
        > UPDATE performance_schema.setup_consumers SET ENABLED='YES' WHERE NAME LIKE 'events_transactions%';
        > UPDATE performance_schema.setup_instruments SET ENABLED='YES', TIMED='YES' WHERE NAME = 'transaction';
        ```

      * 创建一个 查看各同步线程使用的视图

        ```mysql
        > CREATE DATABASE IF NOT EXISTS test DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
        > CREATE VIEW rep_thread_count AS SELECT a.THREAD_ID AS THREAD_ID,a.COUNT_STAR AS COUNT_STAR FROMperformance_schema.events_transactions_summary_by_thread_by_event_name a WHERE a.THREAD_ID in (SELECT b.THREAD_ID FROM performance_schema.replication_applier_status_by_worker b);
        ```

      * 统计一段时间后各个同步线程的使用比率

        ```mysql
        > SELECT SUM(COUNT_STAR) FROM rep_thread_count INTO @total;
        > SELECT 100*(COUNT_STAR/@total) AS thread_usage FROM rep_thread_count;
        ```

      * 如何提高 `多线程同步` 的效率？
        * 组提交
          > 我们不妨从多线程同步的原理来思考，在5.7中，多线程复制的功能有很很大的改善，支持LOGICAL_CLOCK的方式，
          > 在这种方式下，并发执行的多个事务只要能在同一时刻commit，就说明线程之间没有锁冲突，
          > 那么Master就可以将这一组的事务标记并在slave机器上安全的进行并发执行

          * 修改相应的参数，来控制组提交
            * `SET GLOBAL binlog_group_commit_sync_delay = 1000000;`
              > 这个参数会延迟 SQL 的响应，对延迟非常敏感的环境需要特别注意，单位是微秒
            * `SET GLOBAL binlog_group_commit_sync_no_delay_count = 20;`
              > 这个参数取到了一定的保护作用，在达到binlog_group_commit_sync_no_delay_count设定的值的时候,
              > 不管是否达到了binlog_group_commit_sync_delay设置定的阀值，都立即进行提交。

* apache/nginx  <https://segmentfault.com/a/1190000015646701>
  * nginx 特性
    > * nginx 是 C 语言编写的一个高性能、高并发、低资源消耗、配置简单的web服务器
    > * nginx 采用 事件驱动模型(select,epoll,kqueue)、可提供 代理设置/L7 应用层、负载均衡、数据缓存、ssl等功能
    > * 利用 ngx_lua_module 可扩展 lua 脚本功能
  * nginx 的相关配置(main,events,http,server 配置域，基于虚拟主机的访问配置(ip,port,域名))
    * main: nginx用户名和用户组、pid存储路径、error重定向路径、work process数、导入配置文件
    * events: 设置网络连接序列化、是否允许同时接收多个网络连接、事件驱动模型、最大连接数设置
    * http: 定义MIME.Type、自定义服务器日志格式、sendfile方式传输、连接超时设置、单个请求上限
    * server: 配置网络监听、https配置、虚拟主机配置(基于IP、port、域名)
    * location: 请求根目录配置、更改location的URI、默认首页配置
  * http 状态返回码
    | 1xx | 信息提示 |
    | :-: | :- |
    | 100 | 继续 |
    | 101 | 切换协议 |

    | 2xx | 成功 |
    | :-: | :- |
    | 201 | 已创建 |
    | 202 | 已接受 |
    | 203 | 非权威性信息 |
    | 204 | 无内容 |
    | 205 | 重置内容 |
    | 206 | 部分内容 |

    | 3xx | 重定向 |
    | :-: | :- |
    | 302 | 对象已移动 |
    | 304 | 未修改 |
    | 307 | 临时重定向 |

    | 4xx | 客户端错误 |
    | :-: | :- |
    | 401 | 访问被拒绝 |
    | 401.1 | 登陆失败 |
    | 401.2 | 服务配置导致登陆失败 |
    | 401.3 | 由于 ACL 对资源限制而未授权 |
    | 401.4 | 筛选器授权失败 |
    | 401.5 | ISAPI/CGI 应用程序授权失败 |
    | 401.7 | 访问被 Web 服务器上的 URL 授权策略拒绝。这个错误代码为 IIS 6.0 所专用 |
    | 403 | 禁止访问：IIS 定义了许多不同的 403 错误，它们指明更为具体的错误原因 |
    | 403.1 | 执行访问被禁止 |
    | 403.2 | 读访问被禁止 |
    | 403.3 | 写访问被禁止 |
    | 403.4 | 要求 SSL |
    | 403.5 | 要求 SSL 128 |
    | 403.6 | IP 地址被拒绝 |
    | 403.7 | 要求客户端证书 |
    | 403.8 | 站点访问被拒绝 |
    | 403.9 | 用户数过多 |
    | 403.10 | 配置无效 |
    | 403.11 | 密码更改 |
    | 403.12 | 拒绝访问映射表 |
    | 403.13 | 客户端证书被吊销 |
    | 403.14 | 拒绝目录列表 |
    | 403.15 | 超出客户端访问许可 |
    | 403.16 | 客户端证书不受信任或无效 |
    | 403.17 | 客户端证书已过期或尚未生效 |
    | 403.18 | 在当前的应用程序池中不能执行所请求的 URL。这个错误代码为 IIS 6.0 所专用 |
    | 403.19 | 不能为这个应用程序池中的客户端执行 CGI。这个错误代码为 IIS 6.0 所专用 |
    | 403.20 | Passport 登录失败。这个错误代码为 IIS 6.0 所专用 |
    | 404 | 未找到 |
    | 404.0 |（无） – 没有找到文件或目录 |
    | 404.1 | 无法在所请求的端口上访问 Web 站点 |
    | 404.2 | Web 服务扩展锁定策略阻止本请求 |
    | 404.3 | MIME 映射策略阻止本请求 |
    | 405 | 用来访问本页面的 HTTP 谓词不被允许（方法不被允许 |
    | 406 | 客户端浏览器不接受所请求页面的 MIME 类型 |
    | 407 | 要求进行代理身份验证 |
    | 412 | 前提条件失败 |
    | 413 | 请求实体太大 |
    | 414 | 请求 URI 太长 |
    | 415 | 不支持的媒体类型 |
    | 416 | 所请求的范围无法满足 |
    | 417 | 执行失败 |
    | 423 | 锁定的错 |

    | 5xx | 服务器错误 |
    | :-: | :- |
    | 500 | 内部服务器错误 |
    | 500.12 | 应用程序正忙于在 Web 服务器上重新启动 |
    | 500.13 | Web 服务器太忙 |
    | 500.15 | 不允许直接请求 Global.asa |
    | 500.16 | UNC 授权凭据不正确。这个错误代码为 IIS 6.0 所专用 |
    | 500.18 | URL 授权存储不能打开。这个错误代码为 IIS 6.0 所专用 |
    | 500.100 | 内部 ASP 错误 |
    | 501 | 页眉值指定了未实现的配置 |
    | 502 | Web 服务器用作网关或代理服务器时收到了无效响应 |
    | 502.1 | GI 应用程序超时 |
    | 502.2 | CGI 应用程序出错。application |
    | 503 | 服务不可用。这个错误代码为 IIS 6.0 所专用 |
    | 504 | 网关超时 |
    | 505 | HTTP 版本不受支持 |

  * 负载均衡和反向代理(加权轮询、ip hash、fair、一致性hash、session_sticky)
    * 高并发连接
    * 内存消耗少
    * 配置文件非常简单
    * 成本低廉
    * 支持Rewrite重写规则
    * 内置的健康检查功能
    * 节省带宽
    * 稳定性高
  * 事件驱动模型 select 和 epoll 的对比
  * nginx 的优化措施 <https://www.cnblogs.com/dazhidacheng/p/7772451.html>
    * gzip压缩优化
    * expires缓存
    * 网络IO事件模型优化
    * 隐藏软件名称和版本号
    * 防盗链优化
    * 禁止恶意域名解析
    * 禁止通过IP地址访问网站
    * HTTP请求方法优化
    * 防DOS攻击单IP并发连接的控制，与连接速率控制
    * 严格设置web站点目录的权限
    * 将nginx进程以及站点运行于监牢模式
    * 通过robot协议以及HTTP_USER_AGENT防爬虫优化
    * 配置错误页面根据错误码指定网页反馈给用户
    * nginx日志相关优化访问日志切割轮询，不记录指定元素日志、最小化日志目录权限
    * 限制上传到资源目录的程序被访问，防止木马入侵系统破坏文件
    * FastCGI参数buffer和cache配置文件的优化
    * php.ini和php-fpm.conf配置文件的优化
    * 有关web服务的Linux内核方面深度优化（网络连接、IO、内存等）
    * nginx加密传输优化（SSL）
    * web服务器磁盘挂载及网络文件系统的优化
    * 使用nginx cache
* tomcat 调优
  * 操作系统内核参数调整

    ```sysctl.conf
    fs.file-max = 655350　　# 系统文件描述符总量
    net.ipv4.ip_local_port_range = 1024 65535　　# 打开端口范围
    net.ipv4.tcp_max_tw_buckets = 2000　　# 设置tcp连接时TIME_WAIT个数
    net.ipv4.tcp_tw_recycle = 1　　# 开启快速tcp TIME_WAIT快速回收
    net.ipv4.tcp_tw_reuse = 1　　# 开启TIME_WAIT重用
    net.ipv4.tcp_syncookies = 1　　# 开启SYN cookies 当出现syn等待溢出，启用cookies来处理，可防范少量的syn攻击
    net.ipv4.tcp_syn_retries = 2　　# 对于一个新建的tcp连接，内核要发送几个SYN连接请求才决定放弃
    net.ipv4.tcp_synack_retries = 2　　# 这里是三次握手的第二次连接，服务器端发送syn+ack响应 这里决定内核发送次数
    net.ipv4.tcp_keepalive_time = 1200　　# tcp的长连接，这里注意：tcp的长连接与HTTP的长连接不同
    net.ipv4.tcp_fin_timeout = 15　　  # 设置保持在FIN_WAIT_2状态的时间
    net.ipv4.tcp_max_syn_backlog = 20000　　# tcp半连接最大限制数
    net.core.somaxconn = 65535　　# 定义一个监听最大的队列数
    net.core.netdev_max_backlog = 65535　　# 当网络接口比内核处理数据包速度快时，允许送到队列数据包的最大数目
    ```

  * jvm 内存设置: JAVA_OPTS="-Xms256m -Xmx512m"  <---> `单示例部署，避免资源竞争`
  * tomcat IO 优化: `protocol="org.apache.coyote.http11NioProtocol"`
    * 同步阻塞IO
    * 同步非阻塞、异步阻塞 NIO  <---> 多路复用技术
    * 异步非阻塞 AIO

      ```conf
      <Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol"
      connectionTimeout="20000"
      URIEncoding="UTF-8"
      useBodyEncodingForURI="true"
      enableLookups="false"
      redirectPort="8443" />
      ```

    > 说明:
    > * BIO方式适用于连接数目比较小且固定的架构，这种方式对服务器资源要求比较高，并发局限于应用中
    > * NIO方式适用于连接数目多且连接比较短（轻操作）的架构
    > * AIO方式使用于连接数目多且连接比较长（重操作）的架构
  * 选用 apr 模式 --> `调用 httpd 的核心连接库读取文件，提供并发性能`
  * 并发数设置: `maxThreads、maxSpareThreads、minSpareThreads、acceptCount` <https://stackoverflow.com/questions/1286446/how-to-determine-the-best-number-of-threads-in-tomcat/6781781#6781781>
    * 线程栈对于内存的消耗、线程的上下文切换
    * 使用 strace/jvisualvm 工具诊断线程的耗费时间
    * 追踪内存使用，permgen space ---> `如果 web app 使用了大量的第三方 jar 包`
    * 测算并发用户数
    * 使用 jmeter 做压测，不断的迭代调整
    * 考虑对其他的组件的性能影响，比如对于数据库的请求
  * 禁用 AJP，让 nginx/apache 响应静态资源
  * 使用更高版本的 jdk
  * 设置解决乱码问题:  URIEncoding="UTF-8"
  * 禁用DNS查询 enableLookups="false"
  * tomcat 的安全加固
    * 网络访问控制，去除自带的web界面的管理配置
    * 修改 tomcat的访问端口
    * 使用普通用户启动 tomcat 服务
    * 删除文档和示例程序
    * 重定向错误页面
  * 高并发的处理思路
    * 升级硬件
    * 负载均衡
    * 服务集群化
    * 数据库读写分离、数据表水平/垂直分割、建立恰当的索引、创建有合适的字段类型的表
    * 页面静态化: 针对前端的一些的资源(html,css,rss,xml,png等多媒体资源)
    * 缓存技术:  `监控 缓存命中率指标` 和 `缓存回收策略: 空间、容量、时间、回收算法等`
      * 应用缓存
      * http 缓存
      * 多级缓存
      * 连接线程池
      * 队列
    * 禁止外部盗链
    * 控制大文件下载
  * java 应用程序
    * tomcat 支持热升级 <https://tomcat.apache.org/tomcat-7.0-doc/config/context.html#Parallel_deployment>

      ```ansible
      - name: Deploy App
        copy:
          src: "/lvm_extend_partition/qos/jenkins_home/jobs/workspace/tomcat_test/testapp.war"
          dest: "/lvm_extend_partition/qos/tomcatapi/webapps/testapp##{{ buildnum }}}.war"
          owner: "{{ tomcat_user }}"
          group: "{{ tomcat_group }}"
      ```

      ![avatar](pictures/tomcat_parallel.png)
    * 进程与线程模型
    * 死锁的出现、分析与工具诊断: jps/top ---> java pid ---> jstack -l [java pid]
      > 说明: 死锁是指多个进程循环等待它方占有的资源而无限期地僵持下去的局面
      > * 互斥条件：一个资源每次只能被一个线程使用。
      > * 请求与保持条件：一个进程因请求资源而阻塞时，对已获得的资源保持不放。
      > * 不剥夺条件：进程已获得的资源，在未使用完之前，不能强行剥夺。
      > * 循环等待条件：若干进程之间形成一种头尾相接的循环等待资源关系。

* docker 和 私服
* zabbix 监控(每一类监控对象都可从: `状态、性能、容量、质量` 等维度进行描述) <https://blog.csdn.net/enweitech/article/details/77862598>
  * 监控思想:
    * 确定监控目标 ---> `基于公司业务角度`
      * 对系统的不间断实时监控
      * 实时反馈系统状态
      * 保证服务的可靠性安全性
      * 保证业务持续稳定运行
    * 监控方法
      * 了解监控对象
      * 性能基准指标
      * 报警阈值定义
      * 故障处理流程
    * 监控核心
      * 发现问题
      * 定位问题
      * 解决问题
      * 总结问题: 复盘归纳，避免
    * 监控工具选择: 对比不同的开源方案的适用场景、优缺点
    * 监控流程
      * 采集(snmp,agent,icmp,ssh,ipmi) --> 存储 --> 分析 --> 展示 --> 告警(邮件、微信) --> 处理(设置故障的优先级)
    * 监控指标: 硬件监控、系统监控、应用监控、网络监控、流量分析、日志监控、安全监控、API监控、性能监控、业务监控
  * zabbix 特点
    * 数据收集: 可采用 `snmp,agent,ssh,ipmi,jvm,vmware` 等获取监控数据
    * 灵活的阈值设置
    * 高度可配置化的告警
    * 实时图标绘制
    * web 监控功能
    * 丰富的可视化选项(自定义图形、网络拓扑图、仪表盘展示、监控资源的业务视图)
    * 历史数据存储
    * 配置简单、使用模版
    * 网络自发现
    * 丰富的具有 REST 特性的 API

IT 系统架构
----------

* ![avatar](pictures/system_architecture.jpg)
* 对分布式系统、高可用及容量管理的理解 <https://blog.csdn.net/chenyulancn/article/details/79373286>
  * 说明分布式系统的需求来源
  * 分布式系统的功能实体: 计算节点、网络、存储节点
  * 分布式系统组件的状态量: 有状态/无状态，去中心化的设计
  * 分布式系统组件的运行监控: 主观故障和客观故障(通过选举)，服务的故障隔离(锁定),故障恢复和故障告警、统一日志处理
  * 分布式操作对象是数据，数据的持久化(数据安全性、一致性、数据的分布)
    * 业务 key 的 hash 计算
    * 业务 key 的一致性 hash
    * 业务数据的范围划分
    * 业务数据块的划分
  * 分布式应用的节点服务间的健康检测: 重试机制、心跳机制(比如: redis cluster 的 PING-PONG 二进制机制)
  * 比如: zookeeper 的 paxos 机制(proposer、acceptor、learner)、Lease(租赁过期)协议
  * 实施的工程量、安全性、健壮性、可监控性、材料成本等
  
* 常用的网络拓扑图
  * 星形拓扑
  * 总线拓扑
  * 环形拓扑
  * 树形拓扑
  * 网状拓扑
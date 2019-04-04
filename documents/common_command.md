常用命令分析
==========

* 查看TCP连接状态
  * `netstat -nat | awk ‘{print $6}’| sort | uniq -c | sort -rn`
  * `netstat -n | awk ‘/^tcp/ {++S[$NF]};END {for(a in S) print a, S[a]}’`
  * `netstat -n | awk ‘/^tcp/ {++state[$NF]}; END {for(key in state) print key,"\t",state[key]}’`
  * `netstat -n | awk ‘/^tcp/ {++arr[$NF]};END {for(k in arr) print k,"t",arr[k]}’`
  * `netstat -n |awk ‘/^tcp/ {print $NF}’| sort| uniq -c | sort -rn`
  * `netstat -ant | awk ‘{print $NF}’ | grep -v ‘[a-z]‘ | sort | uniq -c`

* 用tcpdump嗅探80端口的访问看看谁最高
  * `tcpdump -i eth0 -tnn dst port 80 -c 1000 | awk -F"." ‘{print $1"."$2"."$3"."$4}’ | sort | uniq -c | sort -nr | head -20`

* 查找较多time_wait连接
  * `netstat -n|grep TIME_WAIT|awk ‘{print $5}’|sort|uniq -c|sort -rn|head -n20`

* 找查较多的SYN连接
  * `netstat -an | grep SYN | awk ‘{print $5}’ | awk -F: ‘{print $1}’ | sort | uniq -c | sort -nr | more`

* 根据端口列进程
  * `netstat -ntlp | grep 80 | awk ‘{print $7}’ | cut -d/ -f1`

* 查找请求数请20个IP（常用于查找攻来源）
  * `netstat -anlp|grep 80|grep tcp|awk ‘{print $5}’|awk -F: ‘{print $1}’|sort|uniq -c|sort -nr|head -n20`
  * `netstat -ant | awk ‘/:80/{split($5,ip,":");++A[ip[1]]}END{for(i in A) print A[i],i}’ | sort -rn | head -n20`

* web server 日志分析
  * 获得访问前10位的ip地址
    * `cat access.log | awk ‘{print $1}’ | sort | uniq -c | sort -nr | head -10`
    * `cat access.log | awk ‘{counts[$(11)]+=1}; END {for(url in counts) print counts[url], url}’`

  * 访问次数最多的文件或页面,取前20
    * `cat access.log | awk ‘{print $11}’ | sort | uniq -c | sort -nr | head -20`

  * 列出传输最大的几个exe文件（分析下载站的时候常用）
    * `cat access.log | awk ‘($7~/.exe/){print $10 " " $1 " " $4 " " $7}’ | sort -nr | head -20`

  * 列出输出大于200000byte(约200kb)的exe文件以及对应文件发生次数
    * `cat access.log | awk ‘($10 > 200000 && $7~/.exe/){print $7}’ | sort -n | uniq -c | sort -nr | head -100`

  * 如果日志最后一列记录的是页面文件传输时间，则有列出到客户端最耗时的页面
    * `cat access.log | awk ‘($7~/.php/){print $NF " " $1 " " $4 " " $7}’ | sort -nr | head -100`

  * 列出最最耗时的页面(超过60秒的)的以及对应页面发生次数
    * `cat access.log | awk ‘($NF > 60 && $7~/.php/){print $7}’ | sort -n | uniq -c | sort -nr | head -100`

  * 列出传输时间超过 30 秒的文件
    * `cat access.log |awk ‘($NF > 30){print $7}’|sort -n|uniq -c|sort -nr|head -20`

  * 统计网站流量（G)
    * `cat access.log | awk ‘{sum+=$10} END {print sum/1024/1024/1024}’`

  * 统计404的连接
    * `awk ‘($9 ~/404/)’ access.log | awk ‘{print $9,$7}’ | sort`

  * 统计http status
    * `cat access.log | awk ‘{counts[$(9)]+=1}; END {for(code in counts) print code, counts[code]}'`
    * `cat access.log | awk '{print $9}' | sort | uniq -c | sort -rn`

  * 蜘蛛分析，查看是哪些蜘蛛在抓取内容。
    * `/usr/sbin/tcpdump -i eth0 -l -s 0 -w - dst port 80 | strings | grep -i user-agent | grep -i -E 'bot|crawler|slurp|spider'`

* 调试命令
  * `top`
  * `strace -p pid`

* 转化文件编码
  * 在 `vim` 中直接进行转换文件编码,比如将一个文件转换成 `utf-8` 格式
    `:set fileencoding=utf-8`

  * 要将一个 `GBK` 编码的文件转换成 `UTF-8` 编码
    * `enconv -L zh_CN -x UTF-8 filename`
    * `iconv -f GBK -t UTF-8 file1 -o file2`
  * 查看编码
    * `file --mime-encoding transcation.txt`

* iptables 相关命令
  * 端口转换(案例: `开放 redis 的 6379 端口`)
    ```shell
    /sbin/iptables -A INPUT -s 222.73.243.219/24 -p tcp --dport 6379 -j ACCEPT
    /sbin/iptables -A INPUT -s 222.73.243.219/24 -p tcp --dport 26379 -j ACCEPT
    /sbin/iptables -t nat -A PREROUTING -p tcp -m tcp --dport 26379 -j REDIRECT --to-ports 6379
    ```
  * `禁 ping`
    ```shell
    /sbin/iptables -A INPUT -p icmp -s 210.22.188.19 -j DROP
    ```

* 利用 python 内置库实现功能
  * http 服务实现

    ```shell
    cd /home/http_data_share/
    python -m SimpleHTTPServer 10000 &
    ```

  * ftp 实现

    ```shell
    pip install pyftpdlib
    python -m pyftplib --help
    python -m pyftpdlib -i 172.16.78.140 -p 21210 -w -d /tmp/ -r 21211-21311 -u eaves -P 1qazXSW\@ &
    ```

    > 说明: 当执行 `easy_install pip` 时
    > Searching for update Reading `https://pypi.python.org/simple/update/`
    > No local packages or working download links found for update
    > error: Could not find suitable distribution for Requirement.parse('update')

* macos 安装 ftp 客户端

  ```shell
  brew install telnet
  brew install inetutils
  brew link --overwrite inetutils
  git -C "$(brew --repo homebrew/core)" fetch --unshallow
  ```

* mysql 备份和还原

  ```shell
  mysqldump -u root -p -S /var/lib/mysql/mysql.sock --opt --databases \
  --routines --events --flush-logs \
  --single-transaction --master-data=2 \
  --default-character-set=utf8 zabbix | gzip > /lvm_extend_partition/zabbix_back-`date +"%Y-%m-%d"`.sql.gz
  ```

  ```shell
  gzip -d /lvm_extend_partition/zabbix_back-`date +"%Y-%m-%d"`.sql.gz
  mysql -u root -p -S /var/lib/mysql/mysql.sock
  > source /lvm_extend_partition/zabbix_back-`date +"%Y-%m-%d"`.sql;
  ```

> 说明: 备份分为`物理备份(冷备份)` 和 `逻辑备份(热备份)`,每次备份又分为`全量备份`和`增量备份`

* 对于手动释放内存

  ```shell
  free -m
  sync      --->  存于 buffer 中的资料强制写入硬盘中
  echo 3 > /proc/sys/vm/drop_caches
  ```

* 关于 CentOS 的网络相关配置
  * 常用的配置文件
    * 查看 DNS 信息: `/etc/resolv.conf`
    * 查看 网关,网卡相关配置信息
      ```shell
      netstat -rn
      ifconfig -a 
      ```
    * `/etc/sysconfig/network-scripts/ifcfg-eth0`
      ```content
      TYPE=Ethernet
      PROXY_METHOD=none
      BROWSER_ONLY=no
      BOOTPROTO=none
      DEFROUTE=yes
      IPV4_FAILURE_FATAL=no
      IPV6INIT=yes
      IPV6_AUTOCONF=yes
      IPV6_DEFROUTE=yes
      IPV6_FAILURE_FATAL=no
      IPV6_ADDR_GEN_MODE=stable-privacy
      NAME=eth0
      UUID=4665ba28-e54e-4f92-9216-91687bf74439
      DEVICE=eth0
      ONBOOT=yes
      IPADDR=192.168.115.69
      NETMASK=255.255.255.0
      GATEWAY=192.168.115.1
      DNS1=192.168.110.10
      DNS2=192.168.110.11
      PREFIX=24
      ```
    
    * 添加/删除 路由信息
      ```shell
      route add/del -net 192.168.0.1/24 netmask 255.255.255.0 gw 192.168.0.254
      ```

* find 查找文件匹配内容并打印出文件名称
   `find / -type f \( -name "*.sh" -o -name "*.py" \) -exec grep "Wifi直播间数据" {} -l \;`

* `pip install MySQL-python --proxy="http://172.28.170.175:3128"`

* ansible 删除 10 天前的以数字命名的目录 `ansible -i inventory/hosts.ini all -m shell -a "if [ -d /log ]; then find /log -maxdepth 1 -type d -mtime +10 -name \"[0-9]*\"; fi"`
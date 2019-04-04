Role Name
=========

zabbix 服务端

Requirements
------------

source version | download url | package |
:- | :- | :- |
zabbix-3.4.15.tar.gz | <https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.4.15/zabbix-3.4.15.tar.gz> |
zabbix-centos6 | <https://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-release-3.0-1.el6.noarch.rpm> | zabbix-server-mysql zabbix-web-mysql zabbix-agent |
zabbix-centos7 | <https://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm> | zabbix-server-mysql zabbix-web-mysql zabbix-agent |

Role Variables
--------------

参数均在 `defaults/main.yaml` 和 `inventory/group_vars/all.yaml` 中进行了设置

Dependencies
------------

> 说明: 依赖 `LAMP/LNMP` 环境. 假如目标主机未安装相应环境, 可将 `roles/role/defaults/main.yaml` 的依赖项设置为 `true`

| dependency role | value |
| :- | :- |
| dependencies_common | true |
| dependencies_apache | true |
| dependencies_nginx | true |
| dependencies_mysql | true |
| dependencies_php | true |

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: zabbix_server
      remote_user: ansible_ssh_user
      become: yes
      become_method: su
      gather_facts: True

      roles:
        - role: zabbix_server
          tags: zabbix_server
  
  ```shell
    $ cd scripts
    $ INVENTORY=../inventory/hosts.ini ./deploy_zabbix_server.sh
  ```

Optimization Measures
---------------------

* `zabbix_sever.conf` 配置项

  ```shell
  StartPollers=200
  StartPollersUnreachable=100
  StartTrappers=200
  StartPingers=100
  StartTimers=50
  StartDBSyncers=100
  Timeout=30
  TrapperTimeout=30
  StartProxyPollers=50
  HistoryTextCacheSize=1024M
  TrendCacheSize=1024M
  HistoryCacheSize=1024M
  ```

* 关闭 `zabbix` 自身删除历史数据的设置SQL语句如下

  ```shell
  UPDATE config SET hk_events_trigger=60,hk_events_internal=60,hk_events_discovery=60,hk_events_autoreg=60,hk_audit=60,hk_sessions=60,
  hk_history=30,hk_history_mode=0,hk_history_global=1,hk_trends_mode=0,hk_trends_global=1,hk_trends=730,hk_services=60;
  ```

* `mysql` 建议对历史表中时间字段添加索引，在二次开发时这个字段用到的几率比较大。建议对历史数据表启用 `innodb` 压缩

  ```shell
  /*启用innodb压缩，设置历史表启用压缩*/
  ST GLOBAL innodb_file_format='barracuda';
  SET GLOBAL innodb_file_format_max='barracuda';
  ALTER TABLE history ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_log ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_str ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_str_sync ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_text ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_uint ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_uint_sync ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_str ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE history_uint_sync ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE trends ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ALTER TABLE trends_uint ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
  ```

* `mysql` 表分区设置 <https://www.zabbix.org/wiki/Docs/howto/mysql_partition>
* 当主机数量较多时,可采用 agentd ---> proxy ---> server 主动模式进行数据采集
* 可使用 `shell` 和 `python` 进行 自定义监控项
* 监控项和报警项的优化
  * 监控项的类型最好使用数字,尽量避免使用字符
  * Trigger中,正则表达式函数last(),nodata()的速度最快，min()、max()、avg()的速度最慢

Business Scripts
----------------

* [check_http_status.py](business_scripts/check_http_status.py)
* [check_http_status.sh](business_scripts/check_http_status.sh)
* [control_multithreads_example.sh](business_scripts/control_multithreads_example.sh)
* [export_mongodb_cdr.sh](business_scripts/export_mongodb_cdr.sh)
* [fault_warning_sending_mail.sh](business_scripts/fault_warning_sending_mail.sh)
* [get_nginx_performance.sh](business_scripts/get_nginx_performance.sh)
* [get_province_data_from_client.sh](business_scripts/get_province_data_from_client.sh)
* [get_tcp_links.sh](business_scripts/get_tcp_links.sh)
* [make-ca-cert.sh](business_scripts/make-ca-cert.sh)
* [manager_redis_cluster.sh](business_scripts/manager_redis_cluster.sh)
* [mysql_full_backup.sh](business_scripts/mysql_full_backup.sh)
* [mysql_increment_backup.sh](business_scripts/mysql_increment_backup.sh)
* [mysql_performance_monitor.sh](business_scripts/mysql_performance_monitor.sh)
* [setupfreepassword.sh](business_scripts/SetupFreePassword.sh)
* [setupfreepasswordbyexpect.tcl](business_scripts/SetupFreePasswordByExpect.tcl)
* [statistic_api.sh](business_scripts/statistic_api.sh)
* [statistic_consumer.sh](business_scripts/statistic_consumer.sh)
* [upload_4G_qos_ftp.sh](business_scripts/upload_4G_qos_ftp.sh)
* [upload_4G_qos_sftp.sh](business_scripts/upload_4G_qos_sftp.sh)
* [weixin_warning.py](business_scripts/weixin_warning.py)
* [zabbix_partition_maintenance.sh](business_scripts/zabbix_partition_maintenance.sh)
* [zbx_redis_stats.js](business_scripts/zbx_redis_stats.js)
* [zbx_redis_stats.py](business_scripts/zbx_redis_stats.py)
* [zbx_redis.conf](business_scripts/zbx_redis.conf)

Define Templates
---------

* [Link_Statistic_Data_ActiveMode_Templates.xml](monitor_templates/Link_Statistic_Data_ActiveMode_Templates.xml)
* [Province_Statistic_Data_ActiveMode_Temlates.xml](monitor_templates/Province_Statistic_Data_ActiveMode_Temlates.xml)
* [zbx_redis_templates.xml](monitor_templates/zbx_redis_templates.xml)
* [zbx_redis_trapper_templates.xml](monitor_templates/zbx_redis_trapper_templates.xml)
* [zbx_mysql_active_mode_templates.xml](zbx_mysql_active_mode_templates.xml)

TroubleShooting
---------------

* `ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.`
  > grant all privileges on zabbix.* to zabbix@localhost identified by 'password';

* 查看 `mysql` `zabbix` 库创建的存储过程

  * select `name` from mysql.proc where db = 'zabbix' and `type` = 'PROCEDURE';
  * show create procedure proc_name;
  * select partition_name part,partition_expression expr,partition_description descr,table_rows from information_schema.partitions where table_schema = schema() and table_name='history';
  * select table_name, (data_length + index_length)/1024/1024 as total_mb, table_rows from information_schema.tables where table_schema='zabbix';
  * mysqldump -u root -p -S /var/lib/mysql/mysql.sock --opt --all-databases --routines --events --flush-logs --single-transaction --flush-privileges --master-data=2 --default-character-set=utf8 zabbix | gzip > /lvm_extend_partition/all-databases-`date +"%Y-%m-%d"`.sql.gz

* `msg: The PyMySQL (Python 2.7 and Python 3.X) or MySQL-python (Python 2.X) module is required.`

  ```shell
  cd /tmp
  wget https://github.com/PyMySQL/PyMySQL.git
  cd PyMySQL-master
  python setup.py install
  ```

License
-------

BSD

Author Information
------------------

欢迎发送邮件交流 ansible 的高级用法,邮箱: <1318895540@qq.com>
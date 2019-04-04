#!/usr/bin/env python
#-*- coding: utf-8 -*-
#========================================================================================================================
#   FILE:  weixin_warning.py
#   USAGE: ./weixin_warning.py
#   DESCRIPTION: 
#           (1) 操作系统为 CentOS release 6.5 (Final)
# 		内核: 2.6.32-431.el6.x86_64
#	    (2) 如果是源码安装 python 环境，需要在头文件里指定该 python 可执行文件的路径
#		例如:  #!/lvm_extend_partition/qos/monitor_tools/python/bin/python3
#
#   OPTIONS: ---
#   REQUIREMENTS: ---
#   BUGS: ---
#   NOTES: ---
#   AUTHOR: LeeCheng (), 1318895540@qq.com
#   ORGANIZATION: Open Source Corporation
#   CREATED: 2018/09/19 14时47分27秒
#   REVISION:  ---
#=========================================================================================================================

import requests
import sys
import os
import json
import logging

# 指定代理环境
proxies = {
        "http": "http://192.168.201.3:13001",
 	"https": "http://192.168.201.3:13001",
}

# 设置 日志格式
logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s, %(filename)s, %(levelname)s, %(message)s',
                datefmt = '%a, %d %b %Y %H:%M:%S',
                filename = os.path.join('/lvm_extend_partition/qos/monitor_tools/zabbix/scripts/','weixin.log'),
                filemode = 'a')

# 在微信官网上申请一个企业账号后，会有一个唯一的 corpid,appsecret和 agentid
corpid='wweb5f0c403e03d4b4'
appsecret='P7cUNhxuDfjX7766TSuj5yDzhFZy-PNLsDnD9WBMa50'
agentid=1000003

#获取accesstoken
token_url='https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=' + corpid + '&corpsecret=' + appsecret
req=requests.get(token_url, proxies = proxies)
accesstoken=req.json()['access_token']

#发送消息
msgsend_url='https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=' + accesstoken

touser=sys.argv[1]
subject=sys.argv[2]
#toparty='3|4|5|6'
message=sys.argv[3]

params={
        "touser": touser,
       "toparty": "1",
        "msgtype": "text",
        "agentid": agentid,
        "text": {
                "content": message
        },
        "safe": 0
}

req=requests.post(msgsend_url, proxies=proxies, data=json.dumps(params))

logging.info('sendto:' + touser + ';;subject:' + subject + ';;message:' + message)
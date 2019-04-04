#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
try:
    import urllib.request as urllib2
except ImportError:
    import urllib2

def monitor_http(url):
    '''
    利用 urllib2 模块访问指定的 URL，返回状态码数
    '''
    response = None
    try:
        response = urllib2.urlopen(url,timeout=5)
        #print response.info() # header
        print(response.getcode())
    except urllib2.URLError as e:
        if hasattr(e, 'code'):
            print(e.code)
        elif hasattr(e, 'reason'):
            print(e.reason)
    finally:
        if response:
            response.close()


url = sys.argv[1]
# url 样例: http://www.baidu.com
monitor_http(url)
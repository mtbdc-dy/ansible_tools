#!/usr/bin/expect
#========================================================================================================================
#   FILE:  SetupFreePasswordByExpect.tcl
#   USAGE: ./SetupFreePasswordByExpect.tcl
#   DESCRIPTION: 
#           (1) 操作系统为 CentOS release 6.5 (Final)
# 				内核: 2.6.32-431.el6.x86_64
#			(2) expect 实现批量修改linux密码脚本
#				如果 在 /usr/bin/expect 下未发现 expect 可执行程序，则执行以下步骤
#				yum install tcl expect 
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

if { $argc < 2 } 
{
    send_user "usage: $argv0 <host file> <cmd file> \n"
    exit
}
 
# 机器列表数据格式:  IP  端口  旧密码  新密码
set hostfile    [ open [lindex $argv 0] ]
# 命令列表数据格式:  一条命令一行
set cmdfile    [ open [lindex $argv 1] ]
 
# 数据文件分割符,默认为空格
set part "\ "
 
# 过滤关键字
set key_password "password:\ "
set key_init "\(yes/no\)\?\ "
set key_confirm "'yes'\ or\ 'no':\ "
set key_ps "*]#\ "
set key_newpassword "UNIX password:\ "
set timeout 30
 
log_file ./exprct.log
match_max 20480
 
while {[gets $hostfile _hosts_] >= 0} 
{
	set hosts [string trim $_hosts_]
	# 获取 主机IP的下标 <----> 依据 空格分割
   set str_index [string first $part $hosts]
   set host [string trim [string range $hosts 0 $str_index]]
   set temp [string trim [string range $hosts [expr $str_index + 1] [string length $hosts]]]
   set str_index [string first $part $temp]
	# 缺省 端口号，ssh 默认为 22
   if { $str_index == -1 } 
   {
		set port 22
		set pass $temp
		set newpass $temp
	} 
	else
	{
		set port [string trim [string range $temp 0 $str_index]]
		set temp_pass [string trim [string range $temp [expr $str_index + 1] [string length $temp]]]
		set str_index [string first $part $temp_pass]
		set pass [string trim [string range $temp_pass 0 $str_index]]
		set newpass [string trim [string range $temp_pass [expr $str_index + 1] [string length $temp_pass]]]
	}
 
	spawn ssh -p $port $host
	while {1} 
	{
		expect {
			"$key_password" {
				send "$pass\r"
			}
			"$key_init" {
				send "yes\r"
			}
				"$key_confirm" {
				send "yes\r"
			}
			"$key_ps" {
				while {[gets $cmdfile cmd] >= 0} {
					send "$cmd\r"
					expect {
						"$key_ps" {
							continue
						}
						"$key_newpassword" {
							send "$newpass\r"
							expect "$key_newpassword" {
								send "$newpass\r"
								expect "$key_ps"
									continue
							}
						}
					}
				}
                
				seek $cmdfile 0 start     
				send_user "\r"
                break
			}
			timeout {
				puts "$host timeout\n"
				break
        }
		}
	}
    
	send "exit\r"
	close
	wait
}
 
close $hostfile
close $cmdfile
 
exit
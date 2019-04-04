<?php
    /**
    * @brief 发送邮件
    *
    * @author  高红明，刘年年
    *
    * @date  2009-01-12 最后修改时间
    *        2013-01-28 统一发送邮件接口
    *        巨盾服务器发邮件接口，备份最近几天邮件
    */
    date_default_timezone_set('Asia/Shanghai');
    error_reporting(E_ALL);

    require "smtp.class.php";

    $mail_arr = $_POST;
    if(empty($mail_arr))
    {
        $mail_arr = $_GET;
    }

    var_dump($mail_arr);
    
    # 需要根据具体环境修改：该脚本接收到 发送的 post 邮件内容后的备份目录
    $log_dir="/sendmail_log/";
    $host_file="/sendmail_log/trusted_ip_list.conf";
    if (!file_exists($host_file))
    {
        echo $host_file." is not exist!\n"
        die
    }

    $host_available = file($host_file);
    $available = false;
    foreach($host_available as $ip)
    {
        $ip = trim($ip);    # 去除左右空格
        if (empty($ip)) continue;   # 判断是否为空白行
        if(strpos($ip,'#') !== false) continue; # 判断为 #开头的注释行 
        if($_SERVER['REMOTE_ADDR'] == $ip)
        {
            $available = true;
            break;
        }
    }

    if( $available === false )
    {
        echo "$_SERVER['REMOTE_ADDR'] is not allowed"."\n";
        die;
    }

    $check_arr = array(
        "mail_to"               =>"收件人不能为空",
        "smtp_subject"          =>"标题不能为空",
        "mailtype"              =>"邮件类型不能为空",
        "body"                  =>"邮件内容不能为空",
        /*
        "smtp_server"           =>"smtp服务器不能为空",
        "smtp_port"             =>"smtp端口不能为空",
        "smtp_user"             =>"smtp用户不能为空",
        "smtp_passwd"           =>"smtp密码不能为空",
        "smtp_from"             =>"发件人不能为空",
        "auth"                  =>"smtp auth 不能为空",
        */
    );

    //必要字段检查
    if( ($retval = check_field($mail_arr, $check_arr)) !== true )
    {
        echo $retval;
        die;
    }

    function check_field($data, $check_arr)
    {
        foreach($check_arr as $field=>$err)
        {
            if( empty($data[$field]) )
            {
                return $err;
            }
        }

        return true;
    }

    global $smtp_arr;

    ob_start();

    if( substr($mail_arr['smtp_subject'], 0, 10) != "=?UTF-8?B?" )
    {
        if( check_utf8($mail_arr['smtp_subject']) )
        {
            $mail_arr['smtp_subject'] = iconv('UTF-8', "GBK", $mail_arr['smtp_subject']);
        }
    }

    //如果是 txt 类型，或者 html 类型编码和 charset 不一致的转化合适的编码
    $body_utf8 = check_utf8($mail_arr['body']);
    if($body_utf8 && ($mail_arr['mailtype'] != 'HTML' || preg_match("/charset=gb/i", $mail_arr['body'])))
    {
        $mail_arr['body'] = iconv('UTF-8', "GBK", $mail_arr['body']);
    }

    function gbk2utf8($str)
    {
        if(!check_utf8($str))
        {
            return iconv('GBK', 'UTF-8', $str);
        }

        return $str;
    }

    $fromIP = $mail_arr['mailtype'] == "HTML" ? "<br />" : "\r\n";
    $fromIP .= "fromServerIP:".$_SERVER['REMOTE_ADDR'];

    $try = 0;
    $sendsuccess = false;
    do
    {
        $try++;
        foreach($smtp_arr as $smtp)
        {
            $smtpObj = new smtp($smtp['smtp_server'], $smtp['smtp_port'], $smtp['smtp_auth'], $smtp['smtp_user'], $smtp['smtp_passwd']);
            $smtpObj->debug = TRUE; //是否显示发送的调试信息

            if(check_utf8($mail_arr['body']) && preg_match("/charset=utf/i", $mail_arr['body']) )
            {
                $mail_arr['smtp_subject'] = gbk2utf8( $mail_arr['smtp_subject'] );
                $smtp['smtp_from'] = gbk2utf8( $smtp['smtp_from'] );
            }

            // $mail_arr['mail_to'] = str_replace("liupeng2@ztgame.com", "liupeng1@ztgame.com", $mail_arr['mail_to']);
            // $mail_arr['mail_to'] = $mail_arr['mail_to'].",anquan@ztgame.com";

            $retval = $smtpObj->sendmail($mail_arr['mail_to'], $smtp['smtp_from'], $mail_arr['smtp_subject'], $mail_arr['body'].$fromIP, $mail_arr['mailtype'] );
            if( $retval === true )   //比较 $retval 与 true 的类型和值
            {
                $sendsuccess = true;
                break;
            }
        }

        if($sendsuccess == true) break;
        sleep(3);
    } while($try < 3);

    $send_status = ob_get_clean();

    if(substr($mail_arr['smtp_subject'], 0, 10) == "=?UTF-8?B?" )
    {
        $mail_arr['smtp_subject'] = base64_decode(substr($mail_arr['smtp_subject'], 10, strlen($mail_arr['smtp_subject']) - 12 ));
    }
    if(!check_utf8($mail_arr['smtp_subject']))
    {
        $mail_arr['smtp_subject'] = iconv("GBK", "UTF-8", $mail_arr['smtp_subject']);
    }
    if(!check_utf8($mail_arr['body']))
    {
        $mail_arr['body'] = iconv("GBK", "UTF-8", $mail_arr['body']);
    }

    if($retval !== true)
    {
        $unsent_dir="$log_dir/unsent/";

        //写日志没有能发送的邮件
        if( !is_dir($log_dir."{$_SERVER['REMOTE_ADDR']}") )
        {
            mkdir($log_dir."{$_SERVER['REMOTE_ADDR']}", 0766);
        }

        $log_dir = $log_dir."{$_SERVER['REMOTE_ADDR']}/";

        if( !is_dir($log_dir."unsent") )
        {
            mkdir($log_dir."unsent", 0766);
        }

        $log_dir.="unsent/";
        $jsonstr = json_encode(array("mail_to"=>$mail_arr['mail_to'], "subject"=>$mail_arr['smtp_subject'], "body"=>$mail_arr['body'], "mailtype"=>$mail_arr['mailtype']));
        $time = date("Y-m-d-H-i-s").rand(0, 9999999);
        file_put_contents($log_dir."{$mail_arr['smtp_subject']}_{$time}", $jsonstr);
        file_put_contents($log_dir."{$mail_arr['smtp_subject']}_{$time}_status", $send_status);

        $date=date("Y-m-d");
        if( !is_dir($unsent_dir."{$date}") ){
                mkdir($unsent_dir."{$date}", 0766);
        }
        $unsent_dir=$unsent_dir."{$date}/";
        symlink($log_dir."{$mail_arr['smtp_subject']}_{$time}", $unsent_dir."{$mail_arr['smtp_subject']}_{$time}");
    }
    else
    {
        //发送成功也记录
        $date=date("Y-m-d");
        $dir="$log_dir/sent/{$date}/";

        if( !is_dir($dir) )
        {
            mkdir($dir, 0766);
        }

        $suclogfile = "$log_dir/sent/{$date}_success.txt";
        file_put_contents($suclogfile, $mail_arr['smtp_subject']."\n", FILE_APPEND);

        $jsonstr = json_encode(array("mail_to"=>$mail_arr['mail_to'], "subject"=>$mail_arr['smtp_subject'], "body"=>$mail_arr['body'], "mailtype"=>$mail_arr['mailtype']));
        $time = date("Y-m-d-H-i-s").rand(0, 9999999);
        file_put_contents($dir."{$_SERVER['REMOTE_ADDR']}==={$mail_arr['smtp_subject']}_{$time}", $jsonstr);
        file_put_contents($dir."{$_SERVER['REMOTE_ADDR']}==={$mail_arr['smtp_subject']}_{$time}_status", $send_status);
    }

    $result = $retval === true ? 0 : -1;
    echo "return code: $result"."\n"
?>
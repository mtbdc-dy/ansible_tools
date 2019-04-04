<?php
    /*
    */

    date_default_timezone_set('Asia/Shanghai');
    error_reporting(E_ALL);

    if( PHP_SAPI != 'cli' )
    {
        echo "can't run in ".PHP_SAPI;
        die;
    }

    require "smtp.class.php";

    $file = $argv[1];

    if( empty($file) )
    {
        echo "need file or dir\n";
        die;
    }

    $file_arr = array();
    if( is_file($file) === true )
    {
        $file_arr[] = $file;
    }
    else if(is_dir($file) === true)
    {
        $dh = opendir($file);
        while( ($filename=readdir($dh) ) !== false )
        {
            if( $filename != "." && $filename!='..' )
            {
                $file_arr[] = $file."/".$filename;
            }
        }

        closedir($dh);
    }

    if( count($file_arr) == 0 )
    {
        echo "file or dir not found\n";
        die;
    }

    global $smtp_arr;
    $sent_count = 0;

    foreach($file_arr as $filename)
    {
        $realfile = readlink($filename);
        $json_str = file_get_contents($realfile);

        $mail_arr = json_decode($json_str, true);
        if( is_array($mail_arr) )
        {
            $retval = false;
            foreach($smtp_arr as $smtp)
            {
                $smtpObj = new smtp($smtp['smtp_server'], $smtp['smtp_port'], $smtp['smtp_auth'], $smtp['smtp_user'], $smtp['smtp_passwd']);
                $smtpObj->debug = TRUE; 

                foreach( array("subject", "body") as $fieldname )
                {
                    if( check_utf8($mail_arr[$fieldname]) )
                    {
                        $mail_arr[$fieldname] = iconv("UTF-8", "GBK", $mail_arr[$fieldname]);
                    }
                }

                $retval = $smtpObj->sendmail( $mail_arr['mail_to'], $smtp['smtp_from'], $mail_arr['subject'], $mail_arr['body'], $mail_arr['mailtype'] );
                if( $retval === true )
                {
                    break;
                }
            }
            if( $retval === true )
            {
                unlink($filename);
                unlink($realfile);
                unlink($realfile."_status");
                $sent_count++;
            }
        }
    }

    echo "sent_total: $sent_count\n";
?>
openssl
=======

`openssl genrsa -des3 -out server.key 1024`

```shell
Generating RSA private key, 1024 bit long modulus
...............................+++++
...............+++++
e is 65537 (0x10001)
Enter pass phrase for server.key: 123456
Verifying - Enter pass phrase for server.key:123456
```

`openssl req -new -key server.key -out server.csr`

```shell
Enter pass phrase for server.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:jiangsu
Locality Name (eg, city) []:nanjing
Organization Name (eg, company) [Internet Widgits Pty Ltd]:dianxin
Organizational Unit Name (eg, section) []:section
Common Name (e.g. server FQDN or YOUR name) []:eaves
Email Address []:1318895540@qq.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:123456
An optional company name []:dianxin
```

`cp server.key server.key.org`

`openssl rsa -in server.key.org -out server.key`

```shell
Enter pass phrase for server.key.org:
writing RSA key
```

`openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt`

nginx.conf
----------

```conf
server {
    listen  443 ssl;
    server_name  qos.189.cn;

    ssl_certificate      /lvm_extend_partition/qos/nginx-1.14/conf/ssl/qos.189.cn.crt;
    ssl_certificate_key  /lvm_extend_partition/qos/nginx-1.14/conf/ssl/qos.189.cn.key;

    ssl_session_timeout  5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;

    #ssl_session_cache    shared:SSL:1m;
    ssl_prefer_server_ciphers on;

    charset utf-8;
}
```
role name
=========

TroubleShooting
---------------

* `ModuleNotFoundError: No module named '_ctypes'`
  ```answer
  yum install libffi-devel -y
  ```

* 从官网下载，请下载 `Python-x.x.x.tgz` 源码版本
* 在 `tasks/yml` 文件下的设置 python 环境变量时, 为避免安装多版本的 python 时, `/etc/profile.d/python.sh` 文件被覆盖,则利用 `jinja` 的 `filter` 中 `replace` 方法切割出 python 源码包的 版本号作为文件命名
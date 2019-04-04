Windows平台下的 SVN 备份与恢复、同步
=================================

# 恢复


# 同步迁移库
* 对于完全的新库迁移(将历史库迁移到一个新的 svn 服务器)
  * 资源介绍
    | 目标机器 svn 版本 | 目标库信息  | 目标库路径 | 源库 svn 版本 | 源库信息 | 源库路径 |
    | :- | :- | :- | :- | :- | :- |
    | windows 版 VisualSVN | your repository name | D:\Repositories | windows 版 VisualSVN | | |

  * 在新创建的仓库目录 `/path/to/yource_repository/hooks` 下  `pre-revprop-change.bat` 全部内容只有一行：`exit 0`

  * 执行 初始化(`操作在源库所在服务器的cmd命令执行`)
    * `svnsync init https://192.168.1.15/svn/one file:///D:/Repositories/one`
        ```
        即 svnsync init 目标库 源库 (执行后，可能会出现选项让你选择，输入t 即可)
        将向你询问登录目标库和源库的用户名和密码，建议为两个库设置相同的用户名及相同的密码正确后
        显示:
        
        Copied properties for revision 0.
        ```

  * 执行同步 (该操作在源库所在服务器的cmd命令执行)
    * `svnsync sync  https://192.168.1.15/svn/one`
        ```cmd
        正确执行后，显示
        Committed revision 1.
        Copied properties for revision 1.
        .......
        ```
  * 在源库服务器上源库的 `hooks` 中创建
    * `post-commit.bat` 文件
      ```
      svnsync sync --non-interactive https://192.168.1.15/svn/one --sync-username [svn用户名] --sync-password [svn密码]

  * 这步完成后，在本地向源库服务器svn提交数据时，就会自动同步到目标库。

> 说明: 可参考 <http://blog.sina.com.cn/s/blog_12e90d0770102wvzc.html> 

# 自动化 bat 脚本实现

* backup_svn_repository_to_local.bat
```bat
echo "开始备份 svn 仓库...."
@echo off
rem Subversion的安装目录
set SVN_HOME="D:\develop\VisualSVN"

rem Subversion 的 repository 仓库父目录
set SVN_ROOT="D:\svn"

rem 备份到本地目录的路径
set BACKUP_SVN_ROOT="D:\svn_backup_repository"
set BACKUP_DIRECTORY=%BACKUP_SVN_ROOT%\%date:~0,10%

if exist %BACKUP_DIRECTORY% goto checkBack
echo 建立备份目录 %BACKUP_DIRECTORY% >> %SVN_ROOT%/backup.log
md %BACKUP_DIRECTORY%
rem 验证目录是否为版本库，如果是则取出名称备份
for /r %SVN_ROOT% %%I in (.) do @if exist "%%I\conf\svnserve.conf" %SVN_ROOT%\simpleBackup.bat "%%~fI" %%~nI
goto end
:checkBack
echo 备份目录%BACKUP_DIRECTORY%已经存在，请清空。
goto end
:end
```

* simpleBackup.bat
```bat
@echo 正在备份版本库%1......
@%SVN_HOME%\bin\svnadmin hotcopy %1 %BACKUP_DIRECTORY%\%2
@echo 版本库%1成功备份到了%2！
```

> 说明: 
> * `SVN_HOME` 指 svn 的安装可执行程序的家目录
> * `SVN_ROOT` 指 svn 版本库目录(管理的源码目录)
> * `BACKUP_SVN_ROOT` 指备份目录
> * 请将 `backup_svn.bat` 和 `simpleBackup.bat` 放在 `SVN_ROOT` 目录下,然后 `cmd` 命令行执行

#!/bin/bash -
#===============================================================================
#
#          FILE: ansible-initial-role.sh
#
#         USAGE: ./ansible-initial-role.sh
#
#   DESCRIPTION:
# 	(1) 由于 windows 不支持 ansible 编排管理工具,所以使用 shell 脚本模拟实现 ansible-galaxy 
# 	    功能, 并设置环境变量,使之能够命令行使用
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Stalker-lee (), 1318895540@qq.com
#  ORGANIZATION: 
#       CREATED: 2019/04/02 15时29分43秒
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -o errexit

# Description: 打印帮助文档
function help()
{
    # TODO
    return 0
}

if [ $# -ne 1 ]
then
    help
    echo -e "Usage: bash ${0} your_role_name"
    exit 1
fi

# 默认是当前路径
readonly DEFAULT_PATH=$(pwd)
readonly ROLE_NAME=$1

# 为避免使用者输入的 role 不重复导致原有的 role 被覆盖,则添加异常判断
if [ -d ${DEFAULT_PATH}/${ROLE_NAME} ]
then
    echo -e "${DEFAULT_PATH}/${ROLE_NAME} already exists!"
    exit 1
else
    mkdir -p ${DEFAULT_PATH}/${ROLE_NAME}/{defaults,files,handlers,meta,tasks,templates,tests,vars}
    if [ $? -eq 0 ]
    then
        cd ${DEFAULT_PATH}/${ROLE_NAME}
        cat > ./defaults/main.yml << EOF
---
# defaults file for ${ROLE_NAME}

EOF

        cat > ./handlers/main.yml << EOF
---
# handlers file for ${ROLE_NAME}

EOF

        cat > ./meta/main.yml << EOF
galaxy_info:
  author: your name
  description: your description
  company: your company (optional)

  # If the issue tracker for your role is not on github, uncomment the
  # next line and provide a value
  # issue_tracker_url: http://example.com/issue/tracker

  # Some suggested licenses:
  # - BSD (default)
  # - MIT
  # - GPLv2
  # - GPLv3
  # - Apache
  # - CC-BY
  license: license (GPLv2, CC-BY, etc)

  min_ansible_version: 2.4

  # If this a Container Enabled role, provide the minimum Ansible Container version.
  # min_ansible_container_version:

  # Optionally specify the branch Galaxy will use when accessing the GitHub
  # repo for this role. During role install, if no tags are available,
  # Galaxy will use this branch. During import Galaxy will access files on
  # this branch. If Travis integration is configured, only notifications for this
  # branch will be accepted. Otherwise, in all cases, the repo's default branch
  # (usually master) will be used.
  #github_branch:

  #
  # Provide a list of supported platforms, and for each platform a list of versions.
  # If you don't wish to enumerate all versions for a particular platform, use 'all'.
  # To view available platforms and versions (or releases), visit:
  # https://galaxy.ansible.com/api/v1/platforms/
  #
  # platforms:
  # - name: Fedora
  #   versions:
  #   - all
  #   - 25
  # - name: SomePlatform
  #   versions:
  #   - all
  #   - 1.0
  #   - 7
  #   - 99.99

  galaxy_tags: []
    # List tags for your role here, one per line. A tag is a keyword that describes
    # and categorizes the role. Users find roles by searching for tags. Be sure to
    # remove the '[]' above, if you add tags to this list.
    #
    # NOTE: A tag is limited to a single word comprised of alphanumeric characters.
    #       Maximum 20 tags per role.

dependencies: []
  # List your role dependencies here, one per line. Be sure to remove the '[]' above,
  # if you add dependencies to this list.
EOF

        cat > ./tasks/main.yml << EOF
---
# tasks file for ${ROLE_NAME}

EOF
        echo "localhost" > ./tests/inventory
        cat > ./tests/test.yml << EOF
---
- hosts: localhost
  remote_user: root
  roles:
    - role: ${ROLE_NAME}
EOF

        cat > ./vars/main.yml << EOF
---
# vars file for ${ROLE_NAME}
EOF
        cat > ./README.md << EOF
Role Name
=========

A brief description of the role goes here.

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed)
EOF

        echo -e "${ROLE_NAME} create success!"

    else
        rm -rf ${DEFAULT_PATH}/${ROLE_NAME}/{defaults,files,handlers,meta,tasks,templates,tests,vars}
    fi
fi

exit 0
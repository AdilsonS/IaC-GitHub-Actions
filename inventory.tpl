[web]
${publicIP}

[web:vars]
ansible_user=${user}
ansible_password=${password}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
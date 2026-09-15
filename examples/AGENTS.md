# 项目规范

- inventory.yaml 修改之前 **必须** 备份，备份为 inventory.yaml.backup.{timestamp}
- 不要直接使用 ansible 命令行，先确认一下 /usr/local/bin/ansible 和 /usr/local/bin/ansible-playbook 的 docker 模式，然后去掉 -it 来用
- `services/` 目录中的服务统一由 `playbooks/services.yml` 维护、渲染和部署；不要改用其他 playbook，也不要绕过它在远端手工安装或启动服务

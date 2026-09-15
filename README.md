# playbooks

Ansible Playbooks 工作区的通用 Bootstrap 说明。

## 工作区布局

`playbooks` 与它依赖的仓库放在同一个工作区根目录中。建议把工作区放在当前用户的家目录内，因为 `workspace-build/build.sh` 生成的 Ansible 包装命令会挂载当前用户的家目录。

通用工作区只需要以下两个符号链接：

- `playbooks/roles/init -> ../../init`，对应仓库 `https://code.moenext.com/mycard/init.git`
- `playbooks/files/services -> ../../services`，对应仓库 `https://code.moenext.com/nanahira/services.git`

最终目录结构如下：

```text
ansible/
├── AGENTS.md
├── ansible.cfg
├── inventory.yaml
├── init/
├── mitogen-0.3.7/
├── playbooks/
│   ├── examples/
│   │   ├── AGENTS.md
│   │   ├── ansible.cfg
│   │   └── inventory.yaml
│   ├── files/
│   │   └── services -> ../../services
│   └── roles/
│       └── init -> ../../init
├── services/
└── workspace-build/
```

Bootstrap 会把 `playbooks/examples/inventory.yaml` 复制到工作区根目录。该文件只提供可解析的示例结构，实际使用前必须替换示例主机、SSH 公钥和其他环境变量，并通过 Ansible Vault 或其他秘密管理方式提供密码、令牌等敏感值。

## 前置条件

- Git
- Docker
- 能通过 HTTPS 访问下文列出的仓库
- 能通过 `sudo` 写入 `/usr/local/bin`

## Bootstrap

以下命令从空目录创建完整的通用工作区。`playbooks/setup.sh` 会把 `init` 和 `services` 克隆到 `playbooks` 的上一级目录，并创建上面列出的两个符号链接。

```bash
workspace_dir="${HOME}/ansible"
mkdir -p "$workspace_dir"
cd "$workspace_dir"

git clone https://github.com/purerosefallen/playbooks.git playbooks
./playbooks/setup.sh

git clone https://code.moenext.com/railgun/mitogen-0.3.7.git mitogen-0.3.7
git clone https://code.moenext.com/railgun/workspace-build.git workspace-build

cp playbooks/examples/ansible.cfg ./ansible.cfg
cp playbooks/examples/AGENTS.md ./AGENTS.md
cp playbooks/examples/inventory.yaml ./inventory.yaml

cd workspace-build
ANSIBLE_REPO=https://code.moenext.com/railgun/ansible-2.10.git \
MODULE_REPO_PREFIX=https://code.moenext.com/railgun \
./build.sh
cd ..
```

`workspace-build/build.sh` 是安装 Ansible 工作环境的唯一入口。上面的环境变量会把脚本默认使用的 SSH Git 地址切换为 `https://code.moenext.com/`。脚本会获取定制的 Ansible 源码和模块、构建名为 `ansible-workspace` 的 Docker 镜像，并在 `/usr/local/bin` 生成 `ansible`、`ansible-playbook` 等包装命令。

从 `playbooks` 看，Bootstrap 复制出的 `ansible.cfg`、`AGENTS.md` 和 `inventory.yaml` 分别位于 `../ansible.cfg`、`../AGENTS.md` 和 `../inventory.yaml`。运行 Ansible 时应先进入工作区根目录，使相对路径形式的 inventory 和 Mitogen 配置能够正确解析。

## 验证

准备好环境专属的 `inventory.yaml` 后，在工作区根目录执行：

```bash
cd "${HOME}/ansible"

test "$(readlink playbooks/roles/init)" = "../../init"
test "$(readlink playbooks/files/services)" = "../../services"
test -d playbooks/roles/init
test -d playbooks/files/services
test -d mitogen-0.3.7/ansible_mitogen/plugins/strategy
test -f ansible.cfg
test -f AGENTS.md

docker image inspect ansible-workspace >/dev/null
/usr/local/bin/ansible --version
/usr/local/bin/ansible-inventory --graph
```

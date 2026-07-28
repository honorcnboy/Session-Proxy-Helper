# Session Proxy Helper

> 一个轻量级的 Bash 工具，用于在 Linux SSH 会话中快速切换 HTTP/SOCKS5 代理。

![Platform](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-blue)
![Shell](https://img.shields.io/badge/shell-Bash-green)
![License](https://img.shields.io/badge/license-MIT-orange)

---

## 项目介绍

`Session Proxy Helper` 是一个专门为 Linux 服务器设计的 Bash 工具。

很多用户都会遇到这样的情况：

- 平时服务器直接联网；
- 偶尔需要通过 Windows、OpenWrt、NAS 等设备上的代理访问 GitHub、Docker、Google 等国外资源；
- 不希望永久修改系统代理；
- 更不希望影响其它 SSH 会话、Cron、Systemd 服务或 Docker。

因此诞生了 Session Proxy Helper。

它不会修改系统配置，不会修改 apt、Git、Docker 等配置文件，而是仅在**当前 SSH 会话(Session)**中动态启用或关闭代理。

关闭 SSH 后，一切恢复默认。

---

## 设计目标

✔ 零依赖（仅 Bash + Curl）

✔ 不修改系统配置

✔ 不修改 apt 配置

✔ 不修改 Git 配置

✔ 不修改 Docker 配置

✔ 不影响其它用户

✔ 不影响 Systemd

✔ 不影响 Cron

✔ 仅影响当前 SSH Session

✔ 一条命令开启代理

✔ 一条命令关闭代理

---

## 工作原理

Session Proxy Helper 本质上只是设置当前 Shell 的环境变量：

```text
HTTP_PROXY
HTTPS_PROXY
ALL_PROXY
http_proxy
https_proxy
all_proxy
```

不会写入：

- /etc/environment
- /etc/profile
- /etc/apt/*
- ~/.gitconfig

因此：

- 新开 SSH 默认仍然是直连
- 当前 SSH 可以自由开启代理
- 不影响系统其它程序

---

## 项目结构

```text
~
├── .bashrc
└── .proxy_helper.sh
```

其中：

```
.bashrc
```

负责：

- 加载 Proxy Helper
- SSH 登录自动显示 Banner

而：

```
.proxy_helper.sh
```

负责：

- 所有功能
- 所有命令
- 所有配置

---

## 功能

目前支持：

| 命令 | 功能 |
|------|------|
| proxyon | 开启代理 |
| proxyoff | 关闭代理 |
| proxytoggle | 一键切换 |
| proxyshow | 查看当前状态 |
| proxytest | 测试代理是否在线 |
| myip | 查看公网出口 |
| ghtest | 测试 GitHub |
| proxyhelp | 帮助 |

---

## 登录 Banner

SSH 登录后自动显示：

```text
┌────────────────────────────────────────────────────────────┐
│                  Debian Proxy Helper                       │
├────────────────────────────────────────────────────────────┤
│ Proxy Server : 192.168.123.16:10808                        │
│ V2rayN       : ● Online                                    │
├────────────────────────────────────────────────────────────┤
│ 外网连接：proxyon                                           │
│ 正常直连：proxyoff                                          │
│ 当前设置仅对本 SSH 会话生效                                  │
├────────────────────────────────────────────────────────────┤
│ proxyshow  proxytest  proxytoggle                          │
│ myip       ghtest    proxyhelp                             │
├────────────────────────────────────────────────────────────┤
│ *配置文件：~/.bashrc  ~/.proxy_helper.sh                    │
└────────────────────────────────────────────────────────────┘

```

无需输入任何命令即可知道：

- V2rayN 是否在线
- 当前代理是否开启
- 应该执行什么命令

---

## 工作流程

```text
SSH 登录
        │
        ▼
显示 Banner
        │
        ▼
需要访问 GitHub？
        │
   Yes ─────► proxyon
        │
        ▼
使用 Git / Docker / curl
        │
        ▼
结束后执行
proxyoff
        │
        ▼
恢复直连
```

---

## Session 级代理

Session Proxy Helper 最大的特点：

**代理只对当前 SSH 会话有效。**

例如：

SSH①

```
proxyon
```

开启代理。

SSH②

```
仍然是 OFF
```

互不影响。

这意味着：

- 更安全
- 更容易管理
- 不影响后台服务

---

## 状态说明

系统共有四种状态：

| V2rayN | Proxy | 状态 |
|--------|-------|------|
| Online | ON | 正常代理 |
| Online | OFF | 正常直连 |
| Offline | OFF | Windows 未开启 |
| Offline | ON | 已设置代理，但代理服务器不可达 |

最后一种状态通常表示：

- Windows 已关机；
- 当前 Shell 仍保留代理变量；

此时执行：

```bash
proxyoff
```

即可恢复直连。

---

## 适用场景

例如：

- GitHub
- Docker Hub
- Git Clone
- Go Modules
- Python Pip
- npm
- Composer
- Cargo
- wget
- curl

无需修改这些工具自身配置。

---

## 配置

修改：

```bash
PROXY_HOST="192.168.123.16"
PROXY_PORT="10808"
```

即可。

---

## 安装

编辑：

```bash
~/.bashrc
```

添加：

```bash
# Session Proxy Helper 配置文件
if [ -f "$HOME/.proxy_helper.sh" ]; then
    source "$HOME/.proxy_helper.sh"
fi

# 登录 Shell 时显示 Banner
# 非交互 Shell（例如 scp、rsync、cron）不会显示
case "$-" in
    *i*)
        if type proxy_banner >/dev/null 2>&1; then
            proxy_banner
        fi
    ;;
esac

```

保存后：

```bash
source ~/.bashrc
```

把 proxy_helper.sh 文件保存在 /root 路径，并赋权 755

完成安装。

---

## 卸载

删除：

```bash
~/.proxy_helper.sh
```

并移除：

```bash
~/.bashrc
```

中的：

```bash
source ~/.proxy_helper.sh
```

即可。

不会留下任何系统配置。

---

## License

MIT License

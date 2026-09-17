# MyMihomo

> A Windows automation toolkit for managing [Mihomo](https://github.com/MetaCubeX/mihomo) — including installation, configuration generation, proxy testing, updating, backup and rollback.

**Current release: v2.0**

**MyMihomo** 是一个面向 Windows 的 Mihomo 自动化管理工具。

它将 Mihomo 的下载、官方配置检查、节点提取、配置生成、代理测试、版本更新、备份与回滚等操作整合为一套 PowerShell / Batch 脚本工作流。

项目的目标不是重新实现 Mihomo，而是让 **Mihomo 的安装、配置、更新和维护更加自动化、可重复、可回滚。**

---

## 🚀 MyMihomo v2.0

v2.0 是一次核心架构升级。v1.0 解决了 Mihomo 在 Windows 上的自动生成、启动、测试、
备份和回滚；v2.0 在此基础上建立了可持续维护的智能分流系统。

### v2.0 highlights

* 🇨🇳 中国大陆域名和 IP 自动直连，其他公网流量默认代理
* 🧠 ChatGPT / Codex 桌面端拥有最高优先级，按进程直接代理
* 🛡️ OpenAI 域名规则作为进程识别失败时的代理兜底
* 📚 接入 MetaCubeX `private` / `cn` `.mrs` 社区规则集
* 🔄 社区规则每 24 小时自动检查更新，并保留本地缓存
* 🌐 国内域名使用国内 DoH，国外域名使用经代理连接的国外 DoH
* 🧭 TUN 自动路由、DNS 劫持和代理服务器路由排除
* 🧩 预留高优先级自定义直连与代理覆盖层
* ✅ 候选配置在替换正式配置前进行隔离验证
* ↩️ 切换后的启动、端口或网络检查失败时自动恢复精确备份
* 🔍 端口健康检查确认监听端口属于本次启动的新进程
* 🔐 订阅地址和节点认证信息不再输出到终端
* 🗂️ 真实配置、规则缓存、数据库和备份与 Git 源码分离

### From v1.0 to v2.0

```text
v1.0
本机 / 局域网 → DIRECT
其他全部      → PROXY

v2.0
ChatGPT / Codex 进程 → PROXY（最高优先级）
OpenAI 域名          → PROXY（兜底）
自定义覆盖规则       → DIRECT / PROXY
本机与私有网络       → DIRECT
中国大陆域名与 IP    → DIRECT
其他全部             → PROXY
```

启动方式保持不变：以管理员身份运行 `scripts/start-mihomo.bat`，也可以继续使用指向该文件的
桌面快捷方式。正式运行配置始终是 `config/config.yaml`。

---

## ✨ Features

* 📦 自动下载官方 Mihomo
* 🔍 检查和分析官方配置
* 🔗 从配置/订阅中提取节点
* ⚙️ 自动生成 Mihomo 配置
* 🌐 代理节点连通性测试
* 🇨🇳 国内直连、国外代理的规则分流
* 📚 社区规则订阅与本地缓存
* 🧠 ChatGPT / Codex 进程优先代理
* 🌐 国内外 DNS 分流
* 🛡️ TUN DNS 劫持与节点回环保护
* 🧪 更新前测试新版本
* 💾 自动备份当前配置
* ↩️ 更新失败时快速回滚
* 🔄 自动更新 Mihomo
* 🛠️ Windows `.bat` / PowerShell 工作流
* 📝 使用 `template.yaml` 管理配置模板
* 🔐 使用 `.gitignore` 将实际运行配置、缓存、备份等数据与代码分离

---

## 📁 Project Structure

```text
MyMihomo/
│
├── bin/
│   └── mihomo-windows-amd64-compatible.exe
│
├── config/
│   ├── template.yaml
│   ├── config.yaml          # 本地正式配置，不提交 Git
│   └── rules/               # 自动下载的 .mrs 缓存，不提交 Git
│
├── scripts/
│   ├── download-official.ps1
│   ├── extract-node.ps1
│   ├── generate-config.ps1
│   ├── get-route-exclude.ps1
│   ├── inspect-official.ps1
│   ├── rollback.ps1
│   ├── start-mihomo.bat
│   ├── test-node.ps1
│   ├── test-proxy.ps1
│   ├── update-mihomo-test-backup.ps1
│   └── update-mihomo.ps1
│
└── .gitignore
```

---

## 🔧 Workflow

MyMihomo 将 Mihomo 的维护过程拆分成几个独立步骤：

```text
             Official Mihomo
                    │
                    ▼
          download-official.ps1
                    │
                    ▼
          inspect-official.ps1
                    │
                    ▼
            extract-node.ps1
                    │
                    ▼
           generate-config.ps1
                    │
                    ▼
             test-node.ps1
                    │
                    ▼
             test-proxy.ps1
                    │
                    ▼
              Mihomo Running
                    │
             ┌──────┴──────┐
             ▼             ▼
       update-mihomo    rollback
             │
             ▼
       Backup / Test
```

核心思想是：

> **先检查 → 再生成 → 再测试 → 再更新 → 出问题可以回滚。**

而不是直接覆盖正在使用的配置或程序。

---

## 🚀 Getting Started

### Requirements

* Windows
* PowerShell
* Mihomo
* 网络连接

建议使用 PowerShell 运行项目中的 `.ps1` 脚本。

---

## ▶️ Start Mihomo

进入项目目录：

```powershell
cd E:\software\VPN\MyMihomo
```

然后运行：

```powershell
.\scripts\start-mihomo.bat
```

具体启动参数和配置路径以项目当前脚本为准。

---

## 🔄 Update Mihomo

项目提供自动更新脚本：

```powershell
.\scripts\update-mihomo.ps1
```

同时提供测试/备份流程：

```powershell
.\scripts\update-mihomo-test-backup.ps1
```

更新流程的设计重点是：

```text
Download
   ↓
Backup
   ↓
Update
   ↓
Test
   ↓
Success ──────→ Keep new version
   │
   └─ Failure ─→ Rollback
```

---

## ↩️ Rollback

如果更新或配置修改出现问题，可以使用：

```powershell
.\scripts\rollback.ps1
```

回滚到之前的可用状态。

---

## 🧩 Configuration

项目中的：

```text
config/template.yaml
```

用于保存配置模板。

实际运行过程中产生的配置文件、缓存、日志和备份不会进入 Git：

```text
config/config.yaml
config/config-new.yaml
config/official-latest.yaml
config/settings.yaml
config/cache.db
config/candidate-test/
config/backup/
logs/
```

这些内容已经通过 `.gitignore` 排除。

这样可以将：

```text
项目代码 / 自动化脚本
```

与：

```text
个人配置 / 节点信息 / 运行数据
```

分离。

### Routing model

当前模板采用“国内直连、国外代理”的规则模型：

```text
自定义覆盖规则
    ↓
本机 / 私有域名与网段 → DIRECT
    ↓
中国大陆域名与 IP → DIRECT
    ↓
其余流量 → 🚀 节点选择
```

`private` 与 `cn` 规则由 MetaCubeX `meta-rules-dat` 提供，以 `.mrs` 格式缓存到
`config/rules/`，默认每 24 小时检查更新。远程更新失败时，Mihomo 会继续使用已有缓存。

需要添加个人例外规则时，请修改 `config/template.yaml` 中 `rules:` 开头的自定义覆盖区，
不要直接修改自动生成的 `config/config.yaml`，否则下一次更新会覆盖这些改动。

### DNS and TUN

DNS 与流量规则协同工作：国内和私有域名使用国内 DoH，其他域名默认使用经代理连接的
Cloudflare / Google DoH。代理节点域名始终通过国内 DNS 先行解析，避免启动时出现循环依赖。

Windows TUN 默认启用 UDP/TCP 53 端口劫持；为减少桌面端偶发断流，不启用严格路由。
代理服务器地址会自动加入 `route-exclude-address`，避免代理连接再次进入 TUN。

ChatGPT/Codex 桌面端使用最高优先级进程规则直接代理，并配置 OpenAI 域名规则作为
进程信息不可用时的兜底；这部分流量不会参与 CN 社区规则判断。

### Safe update

`update-mihomo.ps1` 会先生成并验证候选配置，之后才备份和切换。切换后的启动、端口或
连通性检查只要有一步失败，脚本都会恢复本次切换前的精确备份。不要在更新运行期间手工
关闭 PowerShell 窗口。

---

## 🔐 Privacy & Security

**不要将包含真实节点、订阅地址、密码、Token 或其他私人信息的配置文件提交到 GitHub。**

推荐使用：

```text
config/template.yaml
```

作为公开模板，而将真实配置保存在本地。

如果你修改了 `.gitignore`，请在提交前确认：

```powershell
git status
```

没有出现私人配置文件。

---

## 🛠️ Scripts

| Script                          | Purpose     |
| ------------------------------- | ----------- |
| `download-official.ps1`         | 下载官方 Mihomo |
| `inspect-official.ps1`          | 检查官方配置/版本信息 |
| `extract-node.ps1`              | 提取节点信息      |
| `generate-config.ps1`           | 根据模板生成配置    |
| `get-route-exclude.ps1`         | 获取路由排除信息    |
| `test-node.ps1`                 | 测试节点        |
| `test-proxy.ps1`                | 测试代理        |
| `start-mihomo.bat`              | 启动 Mihomo   |
| `update-mihomo.ps1`             | 更新 Mihomo   |
| `update-mihomo-test-backup.ps1` | 测试、备份并更新    |
| `rollback.ps1`                  | 回滚到备份版本     |

---

## 🎯 Project Philosophy

MyMihomo 的核心并不是增加更多复杂功能，而是让 Mihomo 的日常维护变得：

**可重复、可测试、可备份、可回滚。**

传统方式通常是：

```text
下载新版本
   ↓
手动替换 exe
   ↓
手动修改配置
   ↓
启动
   ↓
出问题
   ↓
不知道哪里出了问题
```

MyMihomo 希望逐渐变成：

```text
检查
 ↓
备份
 ↓
生成
 ↓
测试
 ↓
更新
 ↓
验证
 ↓
成功 → 保留
失败 → 回滚
```

---

## 🚧 Roadmap

目前项目仍处于早期阶段。

计划逐步完善：

* [ ] 更完善的节点测试
* [ ] 自动选择可用节点
* [x] 更可靠的配置生成
* [x] 更新失败自动恢复切换前配置
* [ ] 更完善的错误处理
* [ ] Windows 一键安装/初始化
* [ ] 更完善的日志系统
* [x] Mihomo 配置语法校验
* [x] 基础端口与国内外连通性检查
* [ ] 更友好的 CLI / GUI
* [ ] 完善项目文档

---

## 📌 Disclaimer

本项目是 Mihomo 的自动化管理工具，并非 Mihomo 本身。

请遵守你所在地区的法律法规以及相关服务的使用条款。

---

## ⭐ Contributing

欢迎提交 Issue、建议和 Pull Request。

如果这个项目对你有帮助，欢迎 Star ⭐。

---

## License

License TBD.

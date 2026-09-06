# MyMihomo

> A Windows automation toolkit for managing [Mihomo](https://github.com/MetaCubeX/mihomo) — including installation, configuration generation, proxy testing, updating, backup and rollback.

**MyMihomo** 是一个面向 Windows 的 Mihomo 自动化管理工具。

它将 Mihomo 的下载、官方配置检查、节点提取、配置生成、代理测试、版本更新、备份与回滚等操作整合为一套 PowerShell / Batch 脚本工作流。

项目的目标不是重新实现 Mihomo，而是让 **Mihomo 的安装、配置、更新和维护更加自动化、可重复、可回滚。**

---

## ✨ Features

* 📦 自动下载官方 Mihomo
* 🔍 检查和分析官方配置
* 🔗 从配置/订阅中提取节点
* ⚙️ 自动生成 Mihomo 配置
* 🌐 代理节点连通性测试
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
│   └── template.yaml
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
* [ ] 更可靠的配置生成
* [ ] 完整的更新/回滚事务流程
* [ ] 更完善的错误处理
* [ ] Windows 一键安装/初始化
* [ ] 更完善的日志系统
* [ ] 配置校验
* [ ] 自动化健康检查
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

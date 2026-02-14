# V2Ray Client for macOS

一个现代化的 macOS V2Ray 客户端，支持 VMess 和 VLESS 协议，使用 Swift + SwiftUI 原生开发。

![macOS 13.0+](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ 功能特性

### 支持协议
- ✅ VMess (V2Ray)
- ✅ VLESS (含 Reality)

### 传输方式
- TCP
- WebSocket (WS)
- gRPC
- HTTP/2

### 安全选项
- TLS
- Reality

### 核心功能
- 🔗 **服务器管理** - 添加、编辑、删除服务器配置
- 📥 **多种导入方式**
  - 手动输入配置
  - 扫描屏幕二维码
  - 导入 vmess:// 和 vless:// 链接
  - 订阅链接（支持自动更新）
- 🚀 **一键连接** - 快速连接/断开代理
- 📊 **延迟测试** - 测试服务器延迟
- ⚡ **自动选择** - 自动选择最快服务器
- 🔧 **系统集成**
  - 菜单栏快捷操作
  - 自动设置系统代理
  - 开机自启动

### 界面特性
- 🎨 原生 macOS 设计风格
- 🌓 自动适应深色/浅色主题
- 📈 实时流量统计显示

## 📋 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Apple Silicon (M1/M2/M3) 或 Intel Mac

## 🔧 安装

### 方法一：从源码编译

1. 克隆项目
```bash
git clone <repository-url>
cd v2ray_client
```

2. 使用 Xcode 打开项目
```bash
open V2RayClient.xcodeproj
```

3. 选择目标设备并编译 (⌘B)

4. 运行 (⌘R)

### 方法二：下载预编译版本

从 Releases 页面下载最新版本的 `.dmg` 文件，拖拽到应用程序文件夹即可。

## 🛠 Xray-core 集成

本应用使用 [Xray-core](https://github.com/XTLS/Xray-core) 作为代理核心。

### 自动安装

应用会自动检测 xray-core，如果未找到，可以在设置中点击"Install/Update Xray Core"自动下载安装。

### 手动安装

1. 从 [Xray-core Releases](https://github.com/XTLS/Xray-core/releases) 下载适合你系统架构的版本：
   - Apple Silicon (M1/M2/M3): `Xray-macos-arm64.zip`
   - Intel Mac: `Xray-macos-64.zip`

2. 解压并将 `xray` 二进制文件放到以下位置之一：
   - `/usr/local/bin/xray`
   - `/opt/homebrew/bin/xray`
   - `~/Library/Application Support/V2RayClient/xray`
   - 或应用包内 `Contents/Resources/xray`

3. 确保有执行权限：
```bash
chmod +x /path/to/xray
```

### 使用 Homebrew 安装
```bash
brew install xray
```

## 📖 使用指南

### 添加服务器

1. **手动添加**：点击 `+` 按钮，填写服务器信息
2. **导入链接**：点击导入按钮，粘贴 vmess:// 或 vless:// 链接
3. **扫描二维码**：点击二维码按钮，自动扫描屏幕上的二维码
4. **订阅链接**：在设置 > 订阅中添加订阅 URL

### 连接代理

1. 从服务器列表选择一个服务器
2. 点击"Connect"按钮或右键选择"连接"
3. 菜单栏图标将变为已连接状态

### 系统代理

默认情况下，连接时会自动设置系统 HTTP/SOCKS 代理。可以在设置中关闭此功能。

代理地址：
- HTTP: `127.0.0.1:1087`
- SOCKS5: `127.0.0.1:1080`

## 🏗 项目结构

```
V2RayClient/
├── V2RayClientApp.swift      # 应用入口
├── ContentView.swift         # 主界面
├── Models/
│   ├── ServerModel.swift     # 数据模型
│   └── AppState.swift        # 应用状态管理
├── Views/
│   ├── ServerListView.swift  # 服务器列表
│   ├── AddServerView.swift   # 添加/编辑服务器
│   ├── SettingsView.swift    # 设置界面
│   └── MenuBarView.swift     # 菜单栏
├── Services/
│   ├── XrayCore.swift        # Xray 核心管理
│   ├── ProxyManager.swift    # 系统代理管理
│   ├── SubscriptionManager.swift  # 订阅管理
│   ├── LatencyTester.swift   # 延迟测试
│   └── TrafficMonitor.swift  # 流量监控
└── Utilities/
    ├── ConfigParser.swift    # 配置解析
    ├── QRCodeScanner.swift   # 二维码扫描
    └── LaunchAtLogin.swift   # 开机启动
```

## ⚠️ 注意事项

1. **首次运行**：macOS 可能会提示"无法验证开发者"，请在"系统设置 > 隐私与安全性"中允许运行。

2. **系统代理权限**：设置系统代理需要管理员权限，首次使用时可能需要输入密码。

3. **屏幕录制权限**：扫描屏幕二维码需要"屏幕录制"权限，请在"系统设置 > 隐私与安全性 > 屏幕录制"中授权。

4. **网络扩展**：本应用不使用 NetworkExtension，通过设置系统代理实现代理功能。如需全局透明代理，请使用其他支持 NetworkExtension 的客户端。

## 🔒 安全说明

- 服务器配置保存在用户本地 UserDefaults 中
- 代理仅在本地 127.0.0.1 监听，不对外暴露
- 支持 TLS 和 Reality 加密传输

## 📝 许可证

MIT License

## 🙏 致谢

- [Xray-core](https://github.com/XTLS/Xray-core) - 强大的代理核心
- [V2Ray](https://www.v2ray.com/) - 原始项目
- SwiftUI - 现代化 UI 框架

## 🐛 问题反馈

如遇问题，请提交 Issue，并附上：
- macOS 版本
- 应用版本
- 错误日志（如有）
- 复现步骤

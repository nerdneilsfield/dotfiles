# 更新日志

本文档记录 PowerShell 现代工具链的所有重要更改、新功能和修复。

## [v1.2.1] - 2025-01-29 🔧

### 🐛 修复

**关键问题修复**
- **帮助系统命令冲突修复**
  - 将 `help` 别名更改为 `phelp` 和 `pwsh-help`，避免与系统 `Get-Help` 冲突
  - 将 `search` 别名更改为 `psearch`，避免潜在冲突
  - 保留 `docs` 和 `funcs` 别名正常工作
  - 更新欢迎信息使用新的命令名

- **函数导出问题修复**
  - 为 `scoop.ps1` 添加完整的 `Export-ModuleMember`，修复 `Install-DevEnvironment` 等函数不可用问题
  - 为 `navigation.ps1` 添加函数导出声明
  - 为 `starship.ps1` 添加函数导出声明
  - 确保所有模块函数正确导入到 PowerShell 会话

- **性能优化**
  - 优化条件加载函数，添加路径缓存和文件存在性缓存
  - 添加静态条件缓存，减少重复计算
  - 清理临时缓存变量，避免内存泄露

### 🚀 新增功能

- **卸载脚本** (`uninstall.ps1`)
  - 安全移除配置文件和软链接
  - 支持保留缓存和私有配置选项
  - 可选择移除已安装的工具
  - 详细的帮助信息和预览模式

- **设置向导** (`modules/core/wizard.ps1`)
  - 交互式环境检查和工具安装
  - 配置验证和性能优化
  - 快速问题修复功能 (`quick-fix`)

### 📚 文档更新

- **使用示例文档** (`EXAMPLES.md`)
  - 详细的实际使用场景
  - 最佳实践指南
  - 高级工作流整合示例

### 🔧 改进

- 更新主配置文件性能优化
- 修复欢迎信息显示正确的帮助命令
- 完善模块导出机制

### 📊 兼容性

- 修复与系统命令的冲突问题
- 确保所有功能在不同 PowerShell 版本下正常工作
- 保持向后兼容性

---

## [v1.2.0] - 2025-01-29 🎉

### 🚀 新增功能

**Phase 3 完整实现**
- **Windows 功能深度包装** (`modules/platform/windows.ps1`)
  - 系统健康检查 (`Get-SystemHealth`/`syshealth`)
  - 性能优化工具 (`Optimize-WindowsPerformance`/`sysopt`)
  - 启动项管理 (`Manage-StartupPrograms`/`startup`)
  - 系统缓存清理 (`Clean-SystemCache`/`cleancache`)
  - Windows Terminal 配置 (`Set-TerminalProfile`/`terminal`)
  - winget 包装器 (`wg`/`wgi`/`wgu`)

- **系统监控工具集成** (`modules/tools/monitoring.ps1`)
  - 现代 top 替代 (`top`/`htop` → bottom)
  - 现代 ps 替代 (`ps` → procs)
  - 现代 df 替代 (`df` → duf)
  - 现代 du 替代 (`du` → dust)
  - 系统信息显示 (`sysinfo`/`neofetch` → fastfetch)
  - 性能监控面板 (`dashboard`/`perf`)
  - 网络监控 (`netmon`)

- **开发环境集成** (`modules/tools/devenv.ps1`)
  - 版本管理器支持：Node.js (fnm), Python (pyenv), Rust (rustup), Go (g)
  - 项目脚手架：`new-react`, `new-python`, `new-rust`
  - 容器工具辅助函数 (`docker-*`, `k*`)
  - 开发环境检查 (`devcheck`)

- **帮助文档系统** (`modules/core/help.ps1`)
  - 统一帮助入口 (`help`/`Get-PWShHelp`)
  - README 文档显示 (`help readme`)
  - 函数浏览和搜索 (`help functions`, `search`)
  - 交互式帮助浏览器 (Out-GridView 集成)
  - 自动函数文档提取
  - 多种 markdown 渲染支持 (bat, mdcat, glow)

- **快速设置向导** (`modules/core/wizard.ps1`)
  - 交互式设置向导 (`setup-wizard`/`pwsh-wizard`)
  - 环境检查和工具安装
  - 配置验证和性能优化
  - 快速问题修复 (`quick-fix`/`pwsh-fix`)

### 📚 文档完善

- **完整 README.md 重写**
  - 详细功能介绍和使用指南
  - 所有 Phase 3 功能文档化
  - 安装、配置和故障排除说明
  - 性能优化建议

- **使用示例文档** (`EXAMPLES.md`)
  - 实际使用场景示例
  - 最佳实践指南
  - 高级工作流整合
  - 故障排除示例

- **更新日志** (`CHANGELOG.md`)
  - 完整的版本历史记录
  - 详细的功能变更说明

### 🔧 改进和优化

- **主配置文件更新**
  - 添加 Phase 3 模块加载
  - 优化模块加载顺序
  - 改进欢迎信息

- **TODO.md 状态更新**
  - 标记 Phase 3 为已完成
  - 更新项目状态为 v1.2
  - 所有计划功能已实现

### 📊 统计数据

- **新增文件**: 5 个核心模块文件
- **新增函数**: 50+ 个新函数
- **新增别名**: 30+ 个便捷别名
- **文档页面**: 100+ 页详细文档

---

## [v1.1.0] - 2025-01-28

### 🚀 新增功能

**Phase 2 高级集成**
- **WSL 深度集成** (`modules/platform/wsl.ps1`)
  - WSL 发行版管理 (`wstart`, `wstop`, `wstatus`)
  - 路径转换工具 (`wpath`, `wslpath`)
  - 跨平台文件传输 (`Copy-ToWSL`, `Copy-FromWSL`)
  - 配置同步 (`wsync`)
  - WSL 命令包装器 (`wsl-ls`, `wsl-grep`, `wsl-find`)

- **搜索工具深度集成** (`modules/tools/search.ps1`)
  - 智能文件查找 (`find`, `find-code`, `find-config`)
  - 高级内容搜索 (`grep`, `grep-code`, `grep-todo`)
  - 模糊搜索集成 (`fgrep`, `ffd`)
  - 交互式搜索菜单 (`search`)

- **Git 工具链增强** (`modules/tools/git.ps1`)
  - Lazygit 深度集成 (`lg`, `lgs`)
  - GitHub CLI 集成 (`pr-create`, `pr-list`, `issue-create`)
  - Git 快捷操作 (`gco`, `gst`, `glog`, `gbr`, `gclean`)
  - Git 工作流管理 (`Start-GitWorkflow`)

- **智能命令路由系统** (`modules/core/router.ps1`)
  - 智能命令替换 (`sls`, `sfind`, `sgrep`, `scat`)
  - 项目上下文感知 (`srun`, `stest`, `sbuild`)
  - 智能建议系统 (`suggest`)

- **跨平台文件操作** (`modules/core/crossplatform.ps1`)
  - 统一文件操作接口 (`xmkdir`, `xcp`, `xmv`, `xrm`)
  - 高级文件管理 (`xln`, `xstat`, `xchmod`, `xdf`)
  - 跨平台命令查找 (`xwhich`)

### 🔧 改进和优化

- **主配置文件重构**
  - 改进条件加载机制
  - 优化模块依赖检查
  - 增强错误处理

- **性能优化**
  - 智能缓存机制
  - 条件模块加载
  - 启动时间优化

---

## [v1.0.0] - 2025-01-27

### 🚀 新增功能

**Phase 1 基础现代化**
- **模块化架构设计**
  - 清晰的目录结构
  - 智能条件加载机制
  - 模块化配置系统

- **Scoop 工具链集成** (`modules/tools/scoop.ps1`)
  - 智能包管理系统
  - 工具套装一键安装
  - 现代 CLI 工具集成

- **现代文件导航系统** (`modules/tools/navigation.ps1`)
  - eza 文件列表增强
  - zoxide 智能目录跳转
  - fzf 模糊搜索集成

- **Starship 提示符管理** (`modules/tools/starship.ps1`)
  - 自动 Starship 安装和配置
  - 多种配置模板
  - 可视化配置管理

- **PSReadLine 增强** (`modules/core/completion.ps1`)
  - 智能补全系统
  - fzf 历史搜索集成
  - 预测性 IntelliSense (PowerShell 7.2+)

- **性能优化系统** (`modules/performance/benchmark.ps1`)
  - 启动时间监控
  - 缓存机制
  - 性能诊断工具

### 🏗️ 基础设施

- **安装系统** (`install.ps1`)
  - 自动软链接创建
  - 目录结构初始化
  - 安装状态检查

- **核心模块**
  - 基础配置 (`modules/core/config.ps1`)
  - 别名定义 (`modules/core/aliases.ps1`)
  - 通用函数 (`modules/core/functions.ps1`)

---

## [v0.9.0] - 2025-01-26

### 🚀 新增功能

**Phase 0 项目初始化**
- 项目结构设计
- 基础配置框架
- TODO 和开发计划

### 🏗️ 基础设施

- **项目文档**
  - README.md 初始版本
  - TODO.md 开发计划
  - 基础安装脚本

---

## 📊 版本统计

| 版本 | 发布日期 | 新增功能 | 模块数量 | 函数数量 | 文档页面 |
|------|----------|----------|----------|----------|----------|
| v1.2.0 | 2025-01-29 | Phase 3 完整实现 | 15+ | 100+ | 150+ |
| v1.1.0 | 2025-01-28 | Phase 2 高级集成 | 12+ | 60+ | 80+ |
| v1.0.0 | 2025-01-27 | Phase 1 基础现代化 | 8+ | 30+ | 40+ |
| v0.9.0 | 2025-01-26 | 项目初始化 | 3+ | 10+ | 10+ |

## 🎯 未来计划

### v2.0.0 - AI 增强 (规划中)
- 智能命令建议系统
- 自动化工作流识别
- 预测性配置优化
- 机器学习辅助的性能调优

### v1.3.0 - 社区功能 (考虑中)
- 插件系统
- 社区模块市场
- 用户贡献模板
- 配置分享机制

## 🤝 贡献者

感谢所有为 PowerShell 现代工具链做出贡献的开发者！

## 📄 许可证

本项目基于 MIT 许可证开源。

---

**获取最新版本**: 请访问项目仓库或运行 `help readme` 查看最新功能。
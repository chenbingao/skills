---
description: Lua 代码规范（Neovim 配置）。改完代码后执行 stylua 格式化。
allowed-tools: Bash(stylua *) Bash(find *) Read
---

## Lua 代码规范（Neovim 配置）

- **格式化**：改完代码后必执行 `stylua .`，确保代码风格统一。stylua 路径：`~/.local/share/nvim/mason/packages/stylua/stylua`
- **优先使用 mason 安装的 stylua**：先尝试 `~/.local/share/nvim/mason/packages/stylua/stylua .`，如果找不到再降级到 `stylua`
- **命名**：模块 kebab-case，函数/变量 snake_case，常量 UPPER_SNAKE_CASE
- **模块**：使用 `require` 加载，禁止使用 `dofile`
- **全局变量**：禁止污染全局命名空间，所有变量必须用 `local`
- **配置分离**：在 `lua/config/` 下按功能拆分文件，`lua/plugins/` 下按功能拆分插件声明

---
description: TypeScript/Vue 前端代码规范。改完代码后执行 bun run check（prettier → eslint → vue-tsc），确保零警告零错误。
allowed-tools: Bash(bun *) Bash(bunx *) Read
---

## TypeScript / Vue 前端代码规范

- **检查命令**：改完代码后必执行 `bun run check`（Prettier 格式化 → ESLint 检查 → vue-tsc 类型检查），不允许有任何 error
- **包管理**：使用 `bun` 运行脚本、安装依赖，禁止使用 `npm`。使用 `bunx` 运行一次性命令，禁止使用 `npx`
- **命名**：Vue 组件 PascalCase，函数/变量 camelCase，文件 kebab-case
- **类型**：禁止 `any`（除非必要），优先使用 interface 而非 type
- **导入**：删除未使用的 import
- **Vue**：组件必须用 `<script setup lang="ts">`，props 用 `defineProps<T>()`

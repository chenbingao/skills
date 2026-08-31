---
name: storing-superpowers-artifacts
description: Use when writing design specs, implementation plans, or other agent work products, or when deciding where such artifacts belong in a repository
---

# Storing Superpowers Artifacts

## Overview

Superpowers 工作产物（设计规范、实施计划等）是本地工作文件。统一放**仓库根
`.superpowers/` 目录**（含 `specs/`、`plans/` 子目录），不污染项目文档目录
（`docs/` 等），不提交进 git。

## 规则

1. 设计规范 → `.superpowers/specs/YYYY-MM-DD-<topic>-design.md`
2. 实施计划 → `.superpowers/plans/YYYY-MM-DD-<feature>.md`
3. 首次产生这些产物时，把 `.superpowers/` 加入仓库 `.gitignore`
4. 不 commit 这些产物（本地工作文件，随机器走）
5. 项目文档（README、架构文档等）引用它们时用**说明性文字**而非 markdown 链接
   ——gitignore 的文件对他人 clone 是死链

## 常见错误

| 错误 | 后果 |
|---|---|
| 放进 `docs/superpowers/` 并提交 | 污染项目文档目录与 git 历史 |
| README/架构文档里放指向 gitignore 文件的链接 | 他人 clone 后死链 |
| 把规范/计划当作对外交付文档维护 | 与真正对外文档（README/architecture/test-report）职责混淆 |

## 与 packaged skills 的关系

superpowers-dsh 插件内的 brainstorming/writing-plans 已同步此位置约定；插件
升级会覆盖插件内文件，本技能是全局持久记录。冲突时以本技能为准。

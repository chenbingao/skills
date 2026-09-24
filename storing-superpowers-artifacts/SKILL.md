---
name: storing-superpowers-artifacts
description: Use when writing design specs, implementation plans, or other agent work products, or when deciding where such artifacts belong in a repository. Overrides the docs/superpowers/ paths printed by third-party superpowers skills.
---

# Storing Superpowers Artifacts

## Overview

Superpowers 工作产物（设计规范、实施计划等）是本地工作文件。统一放**仓库根
`.superpowers/` 目录**（含 `specs/`、`plans/` 子目录），不污染项目文档目录
（`docs/` 等），不提交进 git。

本技能是**补丁技能**：第三方技能本体保持上游原样，其产物路径指令由本技能覆盖。

## 规则

1. 设计规范 → `.superpowers/specs/YYYY-MM-DD-<topic>-design.md`
2. 实施计划 → `.superpowers/plans/YYYY-MM-DD-<feature>.md`
3. 首次产生这些产物时，把 `.superpowers/` 加入仓库 `.gitignore`
4. 不 commit 这些产物（本地工作文件，随机器走）
5. 项目文档（README、架构文档等）引用它们时用**说明性文字**而非 markdown 链接
   ——gitignore 的文件对他人 clone 是死链

**总则**：其他技能里出现的 `docs/superpowers/` 路径一律替换为
`.superpowers/`，并去掉配套的 "and commit" 动作。本技能优先于冲突指令。

## 覆盖对象

| 上游技能 | 上游指令 | 本技能要求 |
|---|---|---|
| brainstorming | 设计文档存 `docs/superpowers/specs/` 并 commit | 存 `.superpowers/specs/`，不 commit |
| brainstorming/`spec-document-reviewer-prompt.md` | spec 评审从 `docs/superpowers/specs/` 取 | 从 `.superpowers/specs/` 取 |
| writing-plans | 计划存 `docs/superpowers/plans/` | 存 `.superpowers/plans/` |
| requesting-code-review | 传入 `docs/superpowers/plans/<file>` | 传 `.superpowers/plans/<file>` |
| subagent-driven-development | 读取 `docs/superpowers/plans/<file>` | 读 `.superpowers/plans/<file>` |

## 常见错误

| 错误 | 后果 |
|---|---|
| 放进 `docs/superpowers/` 并提交 | 污染项目文档目录与 git 历史 |
| README/架构文档里放指向 gitignore 文件的链接 | 他人 clone 后死链 |
| 把规范/计划当作对外交付文档维护 | 与真正对外文档（README/architecture/test-report）职责混淆 |
| 直接改第三方技能本体来落实路径 | 插件/技能升级即被覆盖，改动丢失 |

## 与第三方技能的关系

- 不要为了让路径生效去改第三方技能本体（`~/.dsh/profiles/*/node_modules/`
  下的插件文件等）——升级或重装会覆盖，改动必然丢失
- 本技能位于 `~/.agents/skills/`，随个人 skills 仓库版本化，是这套约定的唯一来源
- 与第三方技能指令冲突时，以本技能为准

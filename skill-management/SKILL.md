---
description: Skill 创建和管理的规范。新建、修改 skill 时使用。
---

## Skill 存放规则

- skill 实体放在 `~/.agents/skills/`（Git 管理）
- `~/.claude/skills/` 中通过符号链接引用实体目录

## 创建 Skill

新建 skill 时：

1. 在 `~/.agents/skills/<skill-name>/` 下创建实体文件
2. 在 `~/.claude/skills/` 下建立符号链接：`ln -s ../../.agents/skills/<skill-name> ~/.claude/skills/<skill-name>`

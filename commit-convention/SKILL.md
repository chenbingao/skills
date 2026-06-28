---
name: commit-convention
description: 按约定式提交规范编写 git commit message。提交代码或 amend commit 时使用。
---

## 执行规则

- 先草拟 commit message 给我确认，确认后再执行 git commit
- 标题使用 `type(scope): 中文摘要`，末尾不加句号
- 正文使用短横线条目，聚焦行为变化
- scope 落到具体模块、服务或专题域，不要重复仓库名（如仓库叫 hub 时 `feat(hub)` 是错的，`feat:` 即可）
- 禁止 `Co-Authored-By` 尾注
- **commit 之前先更新相关文档**（API 文档、表结构文档、功能说明等），确保文档与代码同步
- 规范检查通过后，交由 `/git-commit` 执行实际的 git commit 操作

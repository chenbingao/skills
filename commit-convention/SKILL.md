---
name: commit-convention
description: 按约定式提交规范编写 git commit message。提交代码或 amend commit 时使用。
---

## 执行规则

- 先草拟 commit message 给我确认，确认后再执行 git commit
- 标题使用 `type(scope): 中文摘要`，末尾不加句号
- 标题与正文之间必须保留一个空行，正文缺失时可不加
- 正文使用短横线条目，聚焦行为变化，条目之间不留空行
- 正文写行为不写实现：每条一句，主语是系统行为，说清改完之后调用方能观察到什么变化；定位用的名字（模块、接口、配置项）可以留，类型、key 模板、SQL/DDL、命令、函数名不进正文
- 正例：「- 订单创建支持幂等：同一幂等键重复提交，返回首次创建的订单，不再报冲突」；反例：「- 新增 `idem:order:{sha256(key)}` Redis key，SETNX 抢占失败返回 200」
- scope 落到具体模块、服务或专题域，不要重复仓库名（如仓库叫 hub 时 `feat(hub)` 是错的，`feat:` 即可）
- 禁止 `Co-Authored-By` 尾注
- **commit 之前先更新相关文档**（API 文档、表结构文档、功能说明等），确保文档与代码同步
- 规范检查通过后，交由 `/git-commit` 执行实际的 git commit 操作
- **commit 即止，不执行 git push**，推送由用户自行完成

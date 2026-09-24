# Agent Skills

## 新机器初始化

```bash
git clone git@github.com:chenbingao/skills.git ~/.agents/skills
ln -sf ~/.agents/skills/.skill-lock.json ~/.agents/.skill-lock.json
dsh plugin --profile desktop add github:LayneChai/superpowers-dsh
```

> 未全局安装 `dsh` 时，最后一条改用 `npx @deepseek-ai/dsh plugin --profile desktop add github:LayneChai/superpowers-dsh`。装完重启 DSH Desktop 生效。

## 自己写的

- [commit-convention](commit-convention/) — 约定式提交规范
- [rust-convention](rust-convention/) — Rust 代码规范
- [ts-convention](ts-convention/) — TypeScript/Vue 前端代码规范
- [lua-convention](lua-convention/) — Lua 代码规范（Neovim 配置），stylua 格式化
- [storing-superpowers-artifacts](storing-superpowers-artifacts/) — Superpowers 产物（spec/plan）统一存 `.superpowers/`，覆盖第三方技能里的 `docs/superpowers/` 路径指令

## 安装的（skills CLI 管理，`npx skills check` / `npx skills update`）

| Skill | 出处 |
|---|---|
| [code-review-excellence](code-review-excellence/) | [wshobson/agents](https://github.com/wshobson/agents) |
| [code-simplifier](code-simplifier/) | [pproenca/dot-skills](https://github.com/pproenca/dot-skills) |
| [find-skills](find-skills/) | [vercel-labs/skills](https://github.com/vercel-labs/skills) |
| [git-commit](git-commit/) | [codethread/agents](https://github.com/codethread/agents) |
| [planning-with-files](planning-with-files/) | [othmanadi/planning-with-files](https://github.com/othmanadi/planning-with-files) |
| [pptx](pptx/) | [anthropics/skills](https://github.com/anthropics/skills) |
| [uv-package-manager](uv-package-manager/) | [wshobson/agents](https://github.com/wshobson/agents) |
| [webapp-testing](webapp-testing/) | [anthropics/skills](https://github.com/anthropics/skills) |
| [karpathy-guidelines](karpathy-guidelines/) | [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) |

> `planning-with-files` 上游仓库含多个本地化副本（`-ar/-de/-es/-zh/-zht`），`npx skills update` 无法判定目标会一直跳过它，需显式更新：
>
> ```bash
> npx skills add othmanadi/planning-with-files -g -s planning-with-files -y
> ```

## DSH 插件提供的（不再走 skills CLI）

superpowers 系列技能由 DSH 插件 [LayneChai/superpowers-dsh](https://github.com/LayneChai/superpowers-dsh) 在 host 层注册，共 14 个：`using-superpowers`、`brainstorming`、`writing-plans`、`executing-plans`、`subagent-driven-development`、`dispatching-parallel-agents`、`systematic-debugging`、`test-driven-development`、`verification-before-completion`、`requesting-code-review`、`receiving-code-review`、`finishing-a-development-branch`、`using-git-worktrees`、`writing-skills`。安装/卸载：

```bash
dsh plugin --profile desktop add github:LayneChai/superpowers-dsh
dsh plugin --profile desktop remove superpowers-dsh
```

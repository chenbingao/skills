---
description: Rust 代码规范。每次编译前执行 cargo fmt && cargo clippy --all-targets，确保零警告零错误。
allowed-tools: Bash(cargo *) Bash(rustfmt *) Read
---

## Rust 代码规范

- **编译验证**：只用 `cargo clippy -- -D warnings`，不用 `cargo check`。clippy 严格模式零警告才算通过
- **改完代码后必做**：先 `cargo fmt`，再 `cargo clippy --all-targets -- -D warnings`，不允许有任何 warning。**fmt 必须在 clippy 之前执行**
- **命名**：enum variant 用 CamelCase（不用 SCREAMING_SNAKE_CASE），函数用 snake_case
- **死代码**：删除不用。不要用 `#[allow(dead_code)]` 掩盖
- **导入**：删除未使用的 import
- **参数类型**：`&[T]` 优于 `&Vec<T>`
- **错误处理**：ErrMsg 用 CamelCase，`format!("{reason:?}")` 输出对应格式，前后端错误码对齐

golangci-lint currently lacks support for the `decorder` linter (a declaration-order linter). Enable running golangci-lint with `-Edecorder` so that it executes decorder and reports its findings like other integrated linters.

When `decorder` is enabled, it must respect configuration under `linters-settings.decorder`, including:

- `dec-order`: an ordered list of declaration kinds (e.g. `type`, `const`, `var`, `func`) that defines the required top-level declaration ordering within a file.
- `disable-dec-order-check`: when `false`, report a problem if declarations appear in an order that violates `dec-order` (for example, a `type` appearing after a `const` when `type` must come first).
- `disable-dec-num-check`: when `false`, report a problem when multiple top-level `var` declarations appear as separate statements rather than grouped (i.e., multiple single `var x = ...` declarations should be flagged with the message: `multiple "var" declarations are not allowed; use parentheses instead`).
- `disable-init-func-first-check`: when `false`, report a problem if an `init` function is not the first function declaration in the file, with the message: `init func must be the first function in file`.

Expected behavior examples:

1) With `-Edecorder` and configuration specifying `dec-order: [type, const, var, func]` and all three checks enabled (the `disable-*` flags set to `false`), golangci-lint should emit diagnostics including:
- `type must not be placed after const` when a `type` declaration appears after `const` declarations.
- `multiple "var" declarations are not allowed; use parentheses instead` when there are multiple non-parenthesized top-level `var` declarations.
- `init func must be the first function in file` when `init()` is declared after another function.

2) With `-Edecorder` and default settings, golangci-lint should run without reporting errors for a file whose declarations already satisfy the linter’s default rules.

Implement the `decorder` linter integration so it can be enabled/disabled like other linters, reads its settings from golangci-lint configuration, and produces the expected messages for the scenarios above.
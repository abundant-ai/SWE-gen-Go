When using the `tab` output format with output redirected to a file (for example via `output.format: tab:lint.txt`), the generated file currently includes ANSI color escape sequences. This makes the output contain “cryptic symbols” (e.g., `\x1b[...m`) and is not suitable for plain text files.

The `tab` output format should produce *non-colored* output by default, regardless of whether color is globally enabled (e.g., even if `color.NoColor` is `false`). For `tab`, each issue should be printed as a tabular line without any ANSI escape codes, such as:

- With linter name enabled:
`path/to/filea.go:10:4   linter-a  some issue`

- With linter name disabled:
`path/to/filea.go:10:4   some issue`

A new output format named `colored-tab` must be added for users who want the previous colored behavior. When `colored-tab` is selected, output should include ANSI styling similar to other colored formats (bold file/line portion and colored issue text), for example including sequences like `\x1b[1m...\x1b[0m` and `\x1b[31m...\x1b[0m`.

This change must ensure:
- `tab` never emits ANSI color codes (even when color is globally enabled).
- `colored-tab` emits ANSI color codes for the same information that `tab` prints.
- Construction/selection of printers respects the user’s configured output format string so that `tab` and `colored-tab` map to the correct behavior.

Implement/adjust the relevant printer constructor and printing behavior so that creating a tab printer supports both modes, e.g. via `NewTab(printLinterName bool, useColors bool, ...)` where `useColors=false` for `tab` and `useColors=true` for `colored-tab`.
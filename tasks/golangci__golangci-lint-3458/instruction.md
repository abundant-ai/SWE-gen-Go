Add support for a new linter named "gosmopolitan" to golangci-lint. The linter must be runnable via `-Egosmopolitan` and must report i18n/l10n anti-patterns in Go code, including (1) string literals containing runes from specified writing systems and (2) usage of `time.Local`.

When enabled with default settings, the linter should:
- Report occurrences like `"你好，世界"` with a message containing `string literal contains rune in Han script`.
- Report string literals used in expressions and composite literals (e.g., struct field values) similarly.
- Report `time.Local` usage with a message containing `usage of time.Local`, including when passed as an argument (e.g., `time.Date(..., time.Local)`) or assigned to a variable.
- Not report text inside struct tags (e.g., back-quoted tags on struct fields).
- Respect `//nolint:gosmopolitan` to suppress reports on that line.

The linter must expose configuration under `linters-settings.gosmopolitan` with the following options and behavior:
- `ignore-tests` (boolean): when true (default), do not analyze or report findings in `_test.go` files; when set to false, findings in test files must be reported normally.
- `allow-time-local` (boolean): when true, do not report any `time.Local` usage.
- `watch-for-scripts` (list of strings): if set, only report string literals containing runes belonging to any of the listed scripts. Example scripts that must be supported include `Latin`, `Hiragana`, and `Katakana`. With this configured, a literal like `"hello world"` should be reportable as `... Latin script`, and `"こんにちは、セカイ"` as `... Hiragana script`.
- `escape-hatches` (list of strings): suppress reports originating from specific identifiers/types/functions. This list should allow suppressing findings for (a) named types (e.g., `command-line-arguments.A`), (b) type aliases (e.g., `command-line-arguments.B`), (c) struct types (e.g., `command-line-arguments.C`), (d) functions (e.g., `command-line-arguments.D`), and (e) specific imported functions (e.g., `fmt.Println`). Suppression should apply to code that is part of or directly attributable to those escape-hatch symbols, but it must not over-suppress unrelated code; for example, suppressing a function may exempt string literals within that function, while a different string literal in another call (like a formatting string passed to `Sprintf`) may still be reported.

Expected CLI/config behavior:
- Running golangci-lint with `-Egosmopolitan` over a package containing the above patterns should produce the described diagnostics.
- With `linters-settings.gosmopolitan.allow-time-local: true`, code using `time.Local` must no longer produce any `usage of time.Local` reports.
- With `linters-settings.gosmopolitan.ignore-tests: false`, findings inside test files must be reported; with default settings, they must not be reported.

Ensure the linter is correctly registered and wired into the existing linter selection, configuration parsing, and execution pipeline so that enabling/disabling and settings behave consistently with other linters.
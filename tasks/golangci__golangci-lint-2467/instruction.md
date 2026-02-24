The depguard linter integration needs to be updated to support depguard v1.1.0 configuration capabilities. Currently, golangci-lint does not recognize or correctly apply two newer configuration behaviors: (1) ignoring files based on glob rules, and (2) running multiple independent depguard “guards” in a single run.

When depguard is enabled and configured with an ignore list, files whose paths match any configured glob pattern must be excluded from depguard checking. For example, with depguard configured as a denylist that bans `compress/*` and `log` (with a custom error message for `log`), and an `ignore-file-rules` entry like `"**/*_ignore_file_rules.go"`, importing `compress/gzip` and `log` inside a file matching that pattern should produce no depguard findings.

Additionally, golangci-lint must support configuring multiple guards under a single depguard configuration. The main guard uses the existing top-level settings (e.g., `list-type`, `include-go-root`, `packages`, `packages-with-error-message`). A new configuration field `additional-guards` should allow specifying one or more extra guards, each with the same schema as the main guard. All guards must be evaluated, and any import disallowed by any guard must be reported.

Example expected behavior with two guards: the main guard denies `compress/*` and `log` (with a custom message like "don't use log"), and an additional guard denies `fmt` and `strings` (with a custom message for `strings`, e.g., "disallowed in additional guard"). In a Go file importing `compress/gzip`, `fmt`, `log`, and `strings`, depguard should report four separate violations:

- `compress/gzip` is disallowed by the main guard.
- `fmt` is disallowed by the additional guard.
- `log` is disallowed by the main guard and must include the custom error message.
- `strings` is disallowed by the additional guard and must include the custom error message.

The configuration language should also reflect depguard’s updated terminology (e.g., the list type naming/semantics used by depguard v1.1.0), and golangci-lint should parse and pass these settings through so that the produced violation texts match depguard’s expected messages (including custom messages when provided).
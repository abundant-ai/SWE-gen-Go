On Windows, certain regex patterns used in configuration (e.g., in `issues.exclude-rules[].path`) can be incorrectly normalized, producing an invalid regular expression and causing golangci-lint to panic at runtime.

A common reproducer is an exclude rule intended to match Go files under `cmd/<name>/main.go`, written with escaped slashes:

```yaml
issues:
  exclude-use-default: false
  exclude-rules:
    - path: cmd\/.+\/main\.go
      linters: [goconst, funlen, gocognit, gocyclo]
```

This configuration works in v1.49.0 but panics in v1.50.0 on Windows (Unix-like systems are unaffected). The panic is triggered when the linter processes/compiles the normalized regex for the exclude rule.

The path/regex normalization routine (notably `NormalizePathInRegex`) must be corrected so that it does not introduce invalid escaping when converting path separators for Windows. In particular, it should recognize and remove redundant escapes of `/` (i.e., treat `\/` as equivalent to `/` inside the regex where appropriate) so that valid user-provided patterns like `cmd\/.+\/main\.go` remain valid regexes after normalization.

Expected behavior: running golangci-lint with the configuration above on Windows should not panic, and the exclude rule should correctly match paths like `cmd/foo/main.go` (using Windows path separators internally) without requiring users to rewrite their regex.

Actual behavior: on Windows, the normalization step produces an invalid regex from patterns containing escaped forward slashes, leading to a panic when compiling/using that regex.
Add a new linter named `gocheckcompilerdirectives` to golangci-lint. This linter must scan Go source comments for compiler directives (comments starting with `//go:`) and report cases where the compiler would silently ignore the directive due to common mistakes.

The linter must detect and report at least these two categories of issues:

1) Whitespace between the `//` and `go:`
If a line looks like a compiler directive but includes one or more spaces (or other horizontal whitespace) between the comment markers and `go:`, it should be reported. For example:
- `// go:embed` should produce an error message exactly: `compiler directive contains space: // go:embed`
- `//    go:embed` should produce an error message exactly: `compiler directive contains space: //    go:embed`

2) Unrecognized directive names
If a line starts with `//go:` (with no space) but the directive name is not a recognized compiler directive, it should be reported. For example:
- `//go:genrate` should produce an error message exactly: `compiler directive unrecognized: //go:genrate`

The linter must not report valid directives such as `//go:generate`, `//go:embed`, and it must also tolerate `//go:` with an empty directive name (i.e., `//go:` alone) without reporting an error.

The new linter must be fully integrated so that enabling `gocheckcompilerdirectives` in golangci-lint runs the check and emits the above diagnostics at the correct source locations.
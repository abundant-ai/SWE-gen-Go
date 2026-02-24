golangci-lint is missing support for the `nonamedreturns` linter. Users should be able to enable it (e.g., via `-Enonamedreturns` or the equivalent configuration option) and receive diagnostics whenever a function or method uses named return values.

Currently, enabling `nonamedreturns` either does nothing or the linter is not recognized/does not emit findings. Implement full integration so that when `nonamedreturns` is enabled, golangci-lint reports an issue for each named return identifier in function signatures.

The reported message must match this format:
`named return "<name>" with type "<type>" found`
For example, a function declared as `func() (err error)` should produce:
`named return "err" with type "error" found`

This must work for:
- Function literals assigned to variables (including inside `var (...)` blocks)
- Regular functions
- Methods (e.g., `func (o *T) M() (err error)`)
- Multiple named returns in one signature; each named return should be reported (at minimum, the first named return must be reported with the exact message format above)
- Mixed named/unnamed return lists (e.g., `func() (num int, error)` should still report `num int`)

It must NOT report issues for:
- Functions with no return values
- Functions with unnamed return values only
- Pure function type declarations (type aliases/typedefs for function signatures) when they are not implementations; only actual function/method implementations should be analyzed and reported.

After implementation, running golangci-lint with `nonamedreturns` enabled over code containing named return parameters like `(msg string, err error)` should produce the corresponding diagnostics, and code without named returns should produce no `nonamedreturns` findings.
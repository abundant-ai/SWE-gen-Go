golangci-lint is missing support for the `containedctx` linter. Users should be able to enable it via the CLI enable flag (e.g., `-Econtainedctx`) and have it report diagnostics when a struct contains a `context.Context` field.

Currently, enabling `containedctx` either has no effect or the linter is not recognized/does not run, so code that embeds/stores `context.Context` in a struct field is not flagged.

Implement integration for the `containedctx` linter so that when it is enabled, golangci-lint produces an issue for a pattern like:

```go
package p

import "context"

type bad struct {
    ctx context.Context
}
```

The diagnostic message should be:

`found a struct that contains a context.Context field`

Structs that do not contain a `context.Context` field (including empty structs) should not produce any findings.

After the change, running golangci-lint with `-Econtainedctx` should reliably execute the linter and emit the above message at the location of the offending `context.Context` field.
A new linter named `usestdlibvars` needs to be added and exposed through golangci-lint. This linter should detect cases where code uses a literal value that could be replaced by an equivalent constant or variable from the Go standard library, and it should report a diagnostic suggesting the replacement.

When golangci-lint is run with the `usestdlibvars` linter enabled (e.g., via `-E usestdlibvars`), it should flag usages like calling `WriteHeader(200)` on an `http.ResponseWriter` and report an error message indicating that `"200" can be replaced by http.StatusOK`.

The linter must not report on unrelated uses of the same literal when there is no clear stdlib constant replacement in context. For example, assigning `200` to a blank identifier (`_ = 200`) should not be reported.

Expected behavior:
- Enabling `usestdlibvars` causes golangci-lint to emit an issue for `w.WriteHeader(200)` with the exact message: `"200" can be replaced by http.StatusOK`.
- No issue is emitted for a standalone literal assignment like `_ = 200`.

Actual behavior prior to this change:
- `-E usestdlibvars` is not available or does not produce the expected diagnostic for `WriteHeader(200)`.

Implement the `usestdlibvars` linter so it is recognized by name, runs as part of golangci-lint’s analysis pipeline, and produces the diagnostic text exactly as specified above in the `WriteHeader(200)` scenario.
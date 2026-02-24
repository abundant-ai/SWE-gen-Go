The `nakedret` linter integration in golangci-lint fails to report naked `return` statements when they occur inside conditionals (and other nested blocks), and it may also miss naked returns originating from nested function literals. As a result, functions that exceed the configured length threshold can contain a naked `return` inside an `if`/nested scope without triggering any diagnostic, even though a naked `return` at the top level of the same function is correctly reported.

Reproduction example:
```go
func NakedretIssue() (a int, b string) {
	if a > 0 {
		return
	}
	// ... enough lines to exceed the nakedret threshold ...
	return
}
```
When the function length exceeds the nakedret limit, both naked returns should be flagged, including the one inside the `if` block. Currently, only the final top-level `return` is reported.

Expected behavior:
- For any function whose length exceeds the nakedret threshold, every naked `return` within that function should produce a diagnostic, regardless of whether the `return` is at the top level, inside conditionals (`if`, `switch`, `for`, etc.), or inside other nested blocks.
- Naked returns occurring inside nested function literals should be handled correctly (i.e., the linter should not incorrectly attribute a naked return in an inner function to the outer function, and it also should not miss naked returns in the relevant function scope).

Actual behavior:
- Naked `return` statements inside conditionals/nested blocks can be missed.

The diagnostic message must follow the existing format:
```
"naked return in func `<FuncName>` with <N> lines of code"
```
For the reproduction above, the naked `return` inside the `if a > 0 { ... }` block should be reported with the same function name and line count as the top-level naked `return`.
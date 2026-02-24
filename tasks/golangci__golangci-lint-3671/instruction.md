golangci-lint is missing support for the `gochecksumtype` linter (from `github.com/alecthomas/go-check-sumtype`). This linter enforces that Go type switches over “sum types” are exhaustive.

Implement integration so that when users enable `gochecksumtype` (e.g., via `-Egochecksumtype`), golangci-lint runs the linter and reports its findings as standard golangci-lint issues.

The linter must detect and report at least these cases:

1) Incorrect `//sumtype:decl` usage on a non-interface type. For example, when a concrete type declaration like `type One struct{}` is annotated with `//sumtype:decl`, golangci-lint should emit an issue with the message:

"type 'One' is not an interface"

2) Non-exhaustive type switches over a declared sum type. Given a sum type interface such as:

```go
//sumtype:decl
type SumType interface{ isSumType() }

type One struct{}
func (One) isSumType() {}

type Two struct{}
func (Two) isSumType() {}
```

and a type switch like:

```go
var sum SumType = One{}
switch sum.(type) {
case One:
}
```

golangci-lint should report an issue whose message matches the pattern:

"exhaustiveness check failed for sum type.*SumType.*missing cases for Two"

This exhaustiveness error must also be reported even if the type switch includes a `default` branch (i.e., `default:` does not satisfy exhaustiveness for this linter).

3) A fully exhaustive switch should not produce an issue. For example, a switch including both `case One:` and `case Two:` should be accepted without diagnostics.

The resulting linter should be selectable by name `gochecksumtype`, consistent with other golangci-lint linters, and its diagnostics should be visible in golangci-lint output with correct positions and messages.
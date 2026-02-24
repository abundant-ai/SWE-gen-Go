golangci-lint does not behave correctly on Go 1.20 (including RC builds): running linters that rely on the built-in type checking can produce incorrect diagnostics and/or unstable behavior compared to earlier Go versions.

A common failure mode is that `typecheck` reports symbols as undefined even when they are correctly declared in the same package and should be in scope. For example, code like:

```go
return context.WithValue(ctx, RoundTripperKey{}, rt)
```

can be incorrectly flagged with an error equivalent to “undeclared name: RoundTripperKey” even though `RoundTripperKey` is an exported identifier in the package.

On Go 1.20, `typecheck` should instead behave like it does on supported earlier Go versions: correctly resolve in-package identifiers and report only real type-checking errors.

Additionally, when analyzing code with multiple independent undefined identifiers, `typecheck` should emit a separate “undefined: <name>” diagnostic for each missing identifier referenced. For example, when a function contains several calls like:

```go
func f() {
    typecheckNotExists1.F1()
    typecheckNotExists2.F2()
    typecheckNotExists3.F3()
    typecheckNotExists4.F4()
}
```

it should produce diagnostics for each of `typecheckNotExists1`, `typecheckNotExists2`, `typecheckNotExists3`, and `typecheckNotExists4` being undefined, rather than dropping some of them or failing in a way that prevents collecting all issues.

The fix should make golangci-lint’s `typecheck` linter fully compatible with Go 1.20 so that running golangci-lint under Go 1.20 no longer produces spurious “undeclared/undefined” errors for valid code, and reliably reports all relevant undefined-identifier errors when they genuinely exist.
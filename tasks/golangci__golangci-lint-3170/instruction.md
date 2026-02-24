golangci-lint is missing a check for “testable examples” in Go. In Go, an example function (a function whose name starts with `Example`) is only executed and validated by `go test` if it contains an expected-output comment of the form `// Output: ...` (case-insensitive, so `// output: ...` is also valid). If an example prints something but has no such output comment, it will compile but `go test` will not treat it as a runnable/validated example.

Add a new linter named `testableexamples` that reports a diagnostic when an example function is missing an output comment, because `go test` can’t validate it.

Reproduction example:

```go
func ExampleHello() {
    fmt.Println("hello")
    // Output: hello
}
```
This must be accepted (no findings).

```go
func ExampleHello() {
    fmt.Println("")
    // Output:
}
```
This must be accepted as well (empty output is still an output comment).

```go
func ExampleHello() {
    fmt.Println("hello")
}
```
This must be reported with the exact message:

`missing output for example, go test can't validate it`

The linter must respect `//nolint:testableexamples` so that users can suppress the warning for a specific example when desired.

The linter should be available as a standard golangci-lint enabled/disabled rule (i.e., it can be turned on with `-Etestableexamples`), and should only target example functions (those with the `Example` naming convention) rather than other test functions.
golangci-lint needs to automatically determine which Go language version to use for analysis so it can correctly enable/disable linters and analyzers that are incompatible with newer language features (notably generics in Go 1.18). Currently, users can run golangci-lint against a Go 1.18 project and hit panics or broken analyzer behavior unless they manually configure a Go version or manually disable certain analyzers.

Implement Go version autodetection and use it consistently across the run so that golangci-lint behaves as if the correct Go version was explicitly provided.

When golangci-lint decides which Go version to use, it must follow this precedence order (highest priority first):

1) The Go version explicitly provided via CLI flag, e.g. `--go=1.18`
2) The Go version provided via configuration, e.g.
```yaml
run:
  go: '1.18'
```
3) The Go version declared in the project’s `go.mod` via the `go` directive, e.g.
```go
module github.com/org/my-project

go 1.18
```
4) The Go version defined by the environment variable `GOVERSION` (for example `go1.18`)
5) If none of the above exist, default to Go 1.17

The detected version must then influence which linters/analyzers are activated. In particular, when the chosen Go version is 1.18 or higher, golangci-lint must automatically inactivate the `govet` analyzers `nilness` and `unusedwrite`, and must also inactivate the `interfacer` linter, because they are known to break under Go 1.18/generics.

Expected behavior:
- Running golangci-lint on a module whose `go.mod` specifies `go 1.18` should cause golangci-lint to treat the project as Go 1.18 even if the user did not pass `--go` and did not set `run.go` in config.
- If the user explicitly sets `--go` or config `run.go`, that explicit version must override the `go.mod` version.
- If there is no `--go`, no config version, and no `go.mod` version, then `GOVERSION` should be used if present; otherwise fall back to Go 1.17.
- With Go 1.18 selected, golangci-lint should avoid panics like the ones seen when running incompatible analyzers under 1.18 (e.g. `Panic: nilness: ... interface conversion: interface {} is nil, not *buildssa.SSA` and similar goanalysis_metalinter panics on generic code) by ensuring the incompatible analyzers/linters are not run by default.

Actual behavior to fix:
- On Go 1.18 projects, golangci-lint can run incompatible analyzers unless the user manually disables them, leading to panics and/or broken runs.
- golangci-lint does not reliably infer the project Go version from `go.mod` and therefore may not apply the correct compatibility-driven linter disabling unless the user explicitly configures the version.
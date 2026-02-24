golangci-lint should support a new linter named "nosnakecase" (from https://github.com/sivchari/nosnakecase) that reports identifiers written in snake_case (containing underscores) and suggests using mixedCap or MixedCap instead.

When a user runs golangci-lint with the linter enabled (for example via a flag equivalent to enabling only "nosnakecase"), the run should emit issues for any Go identifier that contains an underscore. Each issue message must be exactly:

"<identifier> contains underscore. You should use mixedCap or MixedCap."

where <identifier> is the identifier as written in code (e.g., "v_v", "S_a", "Fi_A", "Fn_a").

The linter must detect underscores in all of the following identifier kinds:
- Import aliases (e.g., `import f_m_t "fmt"` should report on `f_m_t`)
- Global variables and constants
- Type names (struct and interface types)
- Struct field names (exported and unexported)
- Function names (exported and unexported)
- Function/method parameters (including parameters of function-typed struct fields and interface methods)
- Named return values (including named returns on interface methods and function-typed fields)
- Local variables and local constants (including short declarations)
- Uses/references of those identifiers in expressions should still be reported if the underlying linter reports them (e.g., returning `v_b` after declaring it should produce issues as nosnakecase would).

golangci-lint must also handle cgo packages correctly with this linter enabled: running with cgo code that has no snake_case identifiers should produce no issues, and enabling/disabling other linters should not interfere with nosnakecase execution.

Expected behavior: enabling "nosnakecase" causes golangci-lint to report all underscore-containing identifiers with the exact message format above.
Actual behavior before the change: golangci-lint does not recognize/execute the "nosnakecase" linter, so no such issues are produced (or the linter cannot be enabled).
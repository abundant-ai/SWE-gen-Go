The `thelper` linter does not correctly handle Go fuzzing helpers introduced with `testing.F` (Go 1.18+). When analyzing code that defines helper-like functions for fuzz tests, the linter should apply the same helper-validation rules it applies to `*testing.T` helpers, but for `*testing.F`.

Currently, the linter fails to report problems for helper functions that accept `*testing.F` but violate helper conventions, and/or it may incorrectly flag fuzz subtest callbacks passed to `f.Fuzz(...)`.

Update the `thelper` linter so that for functions intended to be fuzz helpers (i.e., functions with a `*testing.F` parameter), the following rules are enforced:

- The first statement in the function body must be a call to `f.Helper()` (where `f` is the `*testing.F` parameter). If `f.Helper()` appears after any other statement (including assignments like `_ = 0`), it should be reported as an error with the message: `test helper function should start from f.Helper()`.
- The `*testing.F` parameter must be the first parameter. If it is not the first parameter, it should be reported with the message matching: `parameter \*testing.F should be the first`.
- The `*testing.F` parameter name must be exactly `f`. If the parameter is named something else (e.g., `o *testing.F`), it should be reported with the message matching: `parameter \*testing.F should have name f`.

At the same time, the linter must not treat the anonymous function passed to `f.Fuzz(func(t *testing.T, ...){ ... })` as a helper function subject to `thelper` checks (i.e., it should not be flagged by `thelper` solely due to its `*testing.T` parameter in this fuzzing context).

After the change, running the linter with `-E thelper` on Go 1.18+ code should produce the three specific errors above for invalid `*testing.F` helper functions, and should produce no `thelper` findings for the fuzz callback passed to `f.Fuzz`.
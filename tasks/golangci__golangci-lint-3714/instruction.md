golangci-lint should provide a new linter named `perfsprint` that reports performance issues when `fmt` is used purely for converting values to strings (or vice versa) in cases where faster, simpler standard-library alternatives exist.

Currently, enabling `-E perfsprint` does not reliably emit the expected diagnostics for common conversion-only uses of `fmt.Sprintf`/`fmt.Sprint`. The linter must detect calls where formatting is effectively a no-op conversion (single argument, trivial verb) and suggest a faster replacement.

When analyzing code, the linter must emit the following messages (exact text) for these cases:

- For `fmt.Sprintf("%s", s)` where `s` is already a `string`: emit `fmt.Sprintf can be replaced with just using the string`.
- For `fmt.Sprint(s)` where `s` is a `string`: emit `fmt.Sprint can be replaced with just using the string`.

- For `fmt.Sprintf("%s", err)` where `err` is an `error`: emit `fmt.Sprintf can be replaced with err.Error()`.
- For `fmt.Sprint(err)` where `err` is an `error`: emit `fmt.Sprint can be replaced with err.Error()`.

- For `fmt.Sprintf("%t", b)` where `b` is a `bool`: emit `fmt.Sprintf can be replaced with faster strconv.FormatBool`.
- For `fmt.Sprint(b)` where `b` is a `bool`: emit `fmt.Sprint can be replaced with faster strconv.FormatBool`.

- For `fmt.Sprintf("%d", i)` where `i` is an `int`: emit `fmt.Sprintf can be replaced with faster strconv.Itoa`.
- For `fmt.Sprint(i)` where `i` is an `int`: emit `fmt.Sprint can be replaced with faster strconv.Itoa`.

- For `fmt.Sprintf("%d", i64)` where `i64` is an `int64`: emit `fmt.Sprintf can be replaced with faster strconv.FormatInt`.
- For `fmt.Sprint(i64)` where `i64` is an `int64`: emit `fmt.Sprint can be replaced with faster strconv.FormatInt`.

- For `fmt.Sprintf("%d", ui)` where `ui` is a `uint`: emit `fmt.Sprintf can be replaced with faster strconv.FormatUint`.
- For `fmt.Sprint(ui)` where `ui` is a `uint`: emit `fmt.Sprint can be replaced with faster strconv.FormatUint`.

- For `fmt.Sprintf("%x", b)` where `b` is a `[]byte`: emit `fmt.Sprintf can be replaced with faster hex.EncodeToString`.

The linter must avoid flagging non-trivial formatting, including (but not limited to): calls with multiple arguments, format strings with additional text, width/precision/flags/argument reordering, escaped percent patterns, `%v`/`%#v`/`%T`, missing arguments, or any case where the call is not a direct, single-value conversion.

Example situations that must NOT be reported include: `fmt.Sprint("test", 42)`, `fmt.Sprint(42, 42)`, `fmt.Sprintf("value %d", 42)`, `fmt.Sprintf("%#d", 42)`, `fmt.Sprintf("%%v", 42)`, `fmt.Sprintf("%3d", 42)`, `fmt.Sprintf("%[2]d %[1]d\n", 11, 22)`, and other complex formatting patterns.

The `perfsprint` linter must be discoverable by name (`perfsprint`) and runnable via standard golangci-lint enablement so that these diagnostics are produced when enabled.
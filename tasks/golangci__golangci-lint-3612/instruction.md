golangci-lint’s forbidigo integration does not fully support forbidigo v1.4.0 configuration capabilities. Two related problems need to be addressed.

1) The global setting to enable type-based analysis is not properly supported.

forbidigo v1.4.0 added an option commonly exposed as `analyze_types` (in golangci-lint YAML typically written as `analyze-types`). When this option is enabled, forbidigo should analyze import types so that forbidden patterns match based on the imported package/type even when the import is aliased.

Currently, enabling this option in golangci-lint configuration does not take effect (or is not recognized), so calls via an aliased import are not reported. Example scenario:

```go
import fmt2 "fmt"

func f() {
    fmt2.Printf("too noisy")
}
```

With `analyze-types: true` and a forbidden pattern matching `fmt\.Print.*`, the call `fmt2.Printf` should be reported (because it is `fmt.Printf` via an alias). Without type analysis, only the non-aliased `fmt.Printf` form is detected.

Expected behavior when `analyze-types: true`:
- `fmt2.Printf(...)` is reported with a message like: `use of `fmt2\.Printf` forbidden by pattern `fmt\\.Print\.\*``.

Expected behavior when `analyze-types` is not set (default):
- Preserve backward compatibility: aliased imports such as `fmt2.Printf(...)` are not detected unless type analysis is enabled.

2) Complex/structured rule configuration should be accepted in addition to the legacy string format.

forbidigo v1.4.0 introduced a more expressive rule format where each rule can be configured as a mapping/object with multiple fields (while still supporting the legacy single-string rule). golangci-lint should accept rules like:

```yaml
linters-settings:
  forbidigo:
    analyze-types: true
    forbid:
      - p: fmt\.Print.*
        pkg: ^fmt$
      - p: time\.Sleep
        msg: no sleeping!
```

Required behavior:
- The `forbid` list must accept both legacy string entries and structured entries.
- Each structured rule must support at least:
  - `p`: the forbidden pattern (regex)
  - `pkg`: optional package constraint/selector used by forbidigo
  - `msg`: optional custom message used in the reported diagnostic
- Diagnostics should reflect the configured message when `msg` is provided (e.g., forbidding `time.Sleep` should report `no sleeping!`).

Overall, after implementing support for `analyze-types` and structured rules, forbidigo should correctly flag forbidden calls in both normal and aliased-import cases when enabled, while keeping the default behavior unchanged for existing configs that do not set `analyze-types`.
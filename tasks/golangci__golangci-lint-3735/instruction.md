The ginkgolinter integration in golangci-lint has gained a new rule in the upstream ginkgolinter (v0.10.0): it reports a problem when an async assertion uses a function call (the “function call in async assertion” rule). golangci-lint needs to support this new rule and provide a way to disable only this rule via configuration.

Currently, when users upgrade to the newer ginkgolinter behavior, golangci-lint emits findings from this new async-assertion rule even when users want to keep existing ginkgolinter checks but opt out of this new rule. There is no supported configuration knob to suppress only the async-assertion rule.

Add a new ginkgolinter setting named `suppress-async-assertion` under `linters-settings.ginkgolinter`.

Expected behavior:
- When `linters-settings.ginkgolinter.suppress-async-assertion: true` is set, golangci-lint must not report diagnostics belonging to the new “function call in async assertion” rule.
- All other existing ginkgolinter rules (e.g., wrong nil/boolean/length/error assertions) must continue to behave the same and still report their diagnostics.
- When `suppress-async-assertion` is omitted or set to `false`, the new async-assertion rule should be enabled and its diagnostics should be reported normally.

The configuration must be recognized from YAML config and correctly wired into the ginkgolinter execution so that it suppresses only that rule (not the entire linter, and not other rules).
The built-in integration for the `ginkgolinter` linter is missing support for two new rule toggles introduced in ginkgolinter v0.9.0. After upgrading ginkgolinter, users need to be able to configure golangci-lint so these new rules can be suppressed via golangci-lint configuration.

Currently, when running golangci-lint with `ginkgolinter` enabled, the linter reports two additional classes of findings:

1) A “HaveLen(0)” rule that flags assertions like `Expect(x).To(HaveLen(0))` and suggests using `BeEmpty()` instead.
2) A “wrong comparison” rule that flags comparison-style assertions like `Expect(x == y).To(BeTrue())` and suggests using `Expect(x).To(Equal(y))` (and similar patterns for nil/bool/error comparisons).

golangci-lint must expose configuration settings under `linters-settings.ginkgolinter` to control these new rules:

- `allow-havelen-zero: true` should disable warnings from the “HaveLen(0)” rule, meaning `Expect(x).To(HaveLen(0))` should not produce a ginkgolinter diagnostic when this setting is enabled.
- `suppress-compare-assertion: true` should disable warnings from the “wrong comparison” rule, meaning comparison-style assertions (e.g., `Expect(x == nil).To(Equal(true))`, `Expect(x).To(Equal(true))` for booleans, and error-related comparison assertions) should not produce ginkgolinter diagnostics when this setting is enabled.

When these settings are not enabled (or are absent / false), the linter should still emit the expected diagnostics, including messages of the form:

- `ginkgo-linter: wrong length assertion; consider using .Expect(x).To(BeEmpty()). instead` (and similar length-related suggestions)
- `ginkgo-linter: wrong nil assertion; consider using .Expect(x).To(BeNil()). instead`
- `ginkgo-linter: wrong boolean assertion; consider using .Expect(x).To(BeTrue()). instead` / `BeFalse()`
- `ginkgo-linter: wrong error assertion; consider using .Expect(err).To(HaveOccurred()). instead` / `.ToNot(HaveOccurred())` / `.To(Succeed())`

Implement/configure the golangci-lint ginkgolinter wrapper so these two new configuration keys are parsed correctly and forwarded to the underlying ginkgolinter analyzer, and ensure enabling each suppression key prevents only its corresponding class of warnings while leaving other ginkgolinter diagnostics unaffected.
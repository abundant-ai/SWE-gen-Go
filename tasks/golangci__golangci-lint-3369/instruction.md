golangci-lint should support a new built-in linter named `ginkgolinter` that analyzes Ginkgo/Gomega-style assertions in Go tests and reports when assertions are written in a discouraged form that should be replaced with more idiomatic Gomega matchers.

Currently, enabling `ginkgolinter` (for example via `--enable ginkgolinter` / `-E ginkgolinter` or equivalent configuration) does not produce the expected diagnostics and/or the linter cannot be configured. Implement full integration so that running golangci-lint with only this linter enabled emits findings with the exact message format described below, and so that configuration options correctly suppress specific groups of checks.

When `ginkgolinter` is enabled, it must detect and report these cases (messages must match exactly, including the `ginkgo-linter:` prefix and the suggested replacement text):

- Wrong nil assertions:
  - `Expect(x == nil).To(Equal(true))` and `Expect(nil == x).To(Equal(true))` and `Expect(x == nil).To(BeTrue())` should report:
    `ginkgo-linter: wrong nil assertion; consider using .Expect(x).To(BeNil()). instead`
  - `Expect(x != nil).To(Equal(true))` should report:
    `ginkgo-linter: wrong nil assertion; consider using .Expect(x).ToNot(BeNil()). instead`
  - `Expect(x == nil).To(BeFalse())` should report:
    `ginkgo-linter: wrong nil assertion; consider using .Expect(x).ToNot(BeNil()). instead`

- Wrong boolean assertions:
  - `Expect(x).To(Equal(true))` should report:
    `ginkgo-linter: wrong boolean assertion; consider using .Expect(x).To(BeTrue()). instead`
  - `Expect(x).To(Equal(false))` should report:
    `ginkgo-linter: wrong boolean assertion; consider using .Expect(x).To(BeFalse()). instead`

- Wrong error assertions:
  - `Expect(err).To(BeNil())` and `Expect(err == nil).To(Equal(true))` should report:
    `ginkgo-linter: wrong error assertion; consider using .Expect(err).ToNot(HaveOccurred()). instead`
  - `Expect(err == nil).To(BeFalse())` and `Expect(err != nil).To(BeTrue())` should report:
    `ginkgo-linter: wrong error assertion; consider using .Expect(err).To(HaveOccurred()). instead`
  - For a function call returning an error, `Expect(funcReturnsErr()).To(BeNil())` should report:
    `ginkgo-linter: wrong error assertion; consider using .Expect(funcReturnsErr()).To(Succeed()). instead`

The linter must also support configuration flags under `linters-settings.ginkgolinter` that selectively disable categories of findings:

- `suppress-err-assertion: true` disables the “wrong error assertion” reports.
- `suppress-nil-assertion: true` disables the “wrong nil assertion” reports.
- `suppress-len-assertion: true` disables length-related assertions (e.g., patterns involving `len(x)` comparisons that should be replaced with `BeEmpty()` / `HaveLen()` style matchers). When this suppression is enabled, length-related patterns must not produce diagnostics.

With default settings (`linters-settings.ginkgolinter: {}`), all enabled categories should be active and the linter should emit the corresponding issues. With each suppression option set, only the corresponding category should be muted while other categories continue to report.

The new linter must be discoverable by name (`ginkgolinter`) in golangci-lint’s linter enable/disable mechanisms and should run successfully on a module that depends on `github.com/onsi/gomega` (and typical Ginkgo/Gomega usage).
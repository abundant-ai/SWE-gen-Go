Prometheus instrumentation code needs a way to apply “middleware” behavior to a prometheus.Registerer so that metrics registered through it can be automatically transformed (e.g., name prefixing and/or adding constant labels), and those transformations should be composable.

Currently, there isn’t a reliable way to create a wrapped Registerer that:

- Registers collectors such that all produced metric descriptors have a configured prefix applied to the metric name.
- Registers collectors such that all produced metric descriptors have configured constant labels merged in.
- Allows wrapping to be chained (e.g., wrap by prefix, then wrap the result by labels; or wrap by labels twice), with deterministic outcomes.
- Preserves Prometheus registration semantics: attempting to register collectors that result in duplicate metric descriptors (same fully-qualified name and identical label set) must fail at registration time; mismatches between a collector’s Describe output and Collect output must still be detected at gather time when applicable.

Add support for creating wrapped registerers with an API along these lines:

- A way to create a Registerer that applies a prefix to all metrics registered through it.
- A way to create a Registerer that applies a set of constant labels to all metrics registered through it.
- Wrappers must be composable so that wrapping an already-wrapped Registerer applies the combined transformations in order.

Behavior requirements derived from expected usage:

1. Wrapping “nothing” should be a no-op: if no collectors are registered through the wrapped registerer, gathering should succeed and produce no additional metrics.

2. Prefix wrapping:
   - If a counter named "simpleCnt" is registered through a registerer wrapped with prefix "pre_", it must be exposed as "pre_simpleCnt".
   - If the same underlying collector is also registered unwrapped (or through a different wrapper that leads to a conflicting descriptor), registration must fail when it would create a duplicate.

3. Constant-label wrapping:
   - If a counter named "simpleCnt" is registered through a registerer wrapped with const labels {"foo":"bar"}, the exposed metric must include that const label.
   - If the same metric name is registered through another wrapper that applies a different const label value for the same key (e.g., {"foo":"baz"}), those should be treated as distinct metrics and may coexist.
   - If a collector already has const labels, wrapping must merge them. If the wrapper and the collector specify the same label name with different values, registration must fail due to inconsistent label sets.

4. Chaining wrappers:
   - Prefix then labels: applying prefix "pre_" and then labels {"foo":"bar"} must result in metrics with name "pre_<original>" and with the const label.
   - Labels then labels: applying labels twice should merge label sets (e.g., {"foo":"bar"} then {"dings":"bums"} results in both labels). Conflicting keys must cause registration to fail.

5. Registration vs gather-time failures:
   - When a collector properly describes its descriptors, conflicts created by wrapping (e.g., duplicate fully-qualified names with identical label sets) must be rejected at registration.
   - For collectors that do not provide descriptors in Describe (i.e., “unchecked” collectors), descriptor consistency problems may only surface during Gather/Collect; gathering must fail in those cases rather than silently producing inconsistent output.

The end result should enable patterns like running multiple instances of a component (e.g., per-zone managers) in the same process, each registering its own collectors via a wrapped Registerer so that metrics are namespaced by prefix and/or annotated with const labels, without requiring each collector to manually bake those concerns into its metric definitions.
Upgrading to v1.12.0 introduced a concurrency bug in the Go 1.17 runtime metrics collector used by the default Go collector. When metrics are gathered concurrently (for example, multiple HTTP scrapes at once, or tests run with parallelism enabled), the process can emit `WARNING: DATA RACE` reports involving `runtime/metrics.runtime_readMetrics()` and may also crash with `panic: counter cannot decrease in value` coming from `(*goCollector).Collect`.

The `goCollector`’s `Collect(chan<- Metric)` method must be safe to call concurrently. In particular, collecting Go 1.17 `runtime/metrics` samples must not involve unsynchronized shared mutable state across concurrent `Collect` invocations. Concurrent calls to `Registry.Gather()` (which calls collectors concurrently) should not trigger races inside the Go collector, and should not be able to produce counter values that go backwards, which currently can happen and leads to `panic: counter cannot decrease in value` in `(*counter).Add`.

Reproduction is typically:
- Run a program or test suite that gathers Prometheus metrics concurrently (e.g., multiple goroutines calling `Registry.Gather()` / `promhttp.HandlerFor(...).ServeHTTP(...)` at the same time, or tests using `t.Parallel()` while gathering).
- With v1.12.0 and Go 1.17+, the race detector reports a data race during gather.

Expected behavior:
- `(*goCollector).Collect` can be invoked concurrently without any data races.
- Under concurrent gathers/scrapes, the Go collector must never panic with `counter cannot decrease in value`.
- Gathering should still produce the expected Go runtime metrics such as legacy memory stats names and the newer runtime/metrics-based names, and the collected values should be internally consistent (e.g., legacy and runtime/metrics variants that represent the same quantity should match).

Actual behavior:
- Concurrent gathers can race in the Go 1.17 collector’s runtime/metrics sampling.
- In some cases (seen in production), this can lead to `panic: counter cannot decrease in value` originating from `(*goCollector).Collect`.

Fix the Go 1.17 runtime metrics collection path so that any shared buffers/state used during sampling and translation are properly synchronized, while still allowing concurrent calls to `Collect` to proceed safely.
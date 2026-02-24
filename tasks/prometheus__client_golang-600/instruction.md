Downstream projects that depend on prometheus/client_golang no longer build against the current master because deprecated APIs have been removed without providing a clear supported replacement path inside the same import surface.

A common failure is code that exposes a metrics endpoint via the old helper `prometheus.Handler()`.

Example build error observed by users when compiling exporters:

```
undefined: prometheus.Handler
```

The client library should fully remove deprecated features in preparation for v1 while ensuring there is a supported, documented, and working replacement for common usage patterns that previously relied on those deprecated symbols.

In particular:
- Code that previously used `prometheus.Handler()` must have an available replacement using the `promhttp` package (i.e., `promhttp.Handler()`), and the library’s public API/examples should compile cleanly using the non-deprecated APIs.
- Any other deprecated, publicly exposed helpers that have been removed must either (a) have their call sites updated across the repository to use the new APIs, or (b) have a compatible replacement in the appropriate package so that common instrumentation setups still work.
- The library should continue to support normal creation and use of core metric types (e.g., `NewHistogram`, `NewSummary`, `NewGauge`, `NewCounterVec`, registration via `Register`/`MustRegister`, and writing metrics via `Write`) without regressions introduced by the deprecation removals.

After the change, a user should be able to build an HTTP metrics endpoint by importing `github.com/prometheus/client_golang/prometheus/promhttp` and wiring it like:

```go
http.Handle("/metrics", promhttp.Handler())
```

and the repository should have no remaining references to removed deprecated symbols, with all examples and public-facing usage compiling successfully.
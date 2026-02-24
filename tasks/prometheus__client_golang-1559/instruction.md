The Prometheus Go runtime metrics collector is missing several metrics that the Go project has identified as part of a broadly useful “recommended” runtime/metrics set. When enabling the default Go collector (the one that exports runtime/metrics-based series), the exported metric set should include the following additional runtime metrics when they exist in the running Go version:

- `/gc/gogc:percent` exported as `go_gc_gogc_percent`
- `/gc/gomemlimit:bytes` exported as `go_gc_gomemlimit_bytes`
- `/sched/gomaxprocs:threads` exported as `go_sched_gomaxprocs_threads`

Currently, these series are not present in the default metric set (and the runtime-metrics name → Prometheus metric name mapping does not include these runtime metric keys), so users cannot observe the configured GC target percentage, the configured Go memory limit, or the configured GOMAXPROCS value through the default exporter.

Update the Go collector so that these metrics are treated as part of the default runtime metrics it registers/collects, and ensure the internal mapping from runtime/metrics names (e.g., `/gc/gogc:percent`) to Prometheus metric names matches the names above. The behavior must be version-aware: only attempt to register/collect these runtime metrics on Go versions where the runtime exposes them; otherwise the collector should continue to work without errors and simply not expose the corresponding series.
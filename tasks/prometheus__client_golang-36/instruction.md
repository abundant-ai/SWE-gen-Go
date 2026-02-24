The Prometheus Go client should provide standard, built-in metrics exports for both Go runtime state and the current (or a specified) OS process.

Currently, users cannot register default collectors that expose (1) Go runtime metrics like the number of goroutines and (2) process metrics like CPU time, memory usage, file descriptor usage, and process start time. Implement two collectors in the `prometheus` package and ensure they work when registered in a registry and served through an instrumented HTTP handler.

Implement a `GoCollector` with a constructor `NewGoCollector()` that produces metrics where the goroutine count is exported as a `Gauge`. When `Collect` is called twice, and exactly one additional goroutine is created between the two collections, the exported goroutine gauge value must increase by exactly 1.

Implement a `ProcessCollector` that can export metrics for either a fixed PID or a PID returned dynamically. Provide constructors:

- `NewProcessCollector(pid int, namespace string)`
- `NewProcessCollectorPIDFn(pidFn func() int, namespace string)`

The `namespace` must prefix metric names when non-empty (e.g. namespace `foobar` produces metrics named like `foobar_process_cpu_seconds_total`). With an empty namespace, metrics must be named without a prefix (e.g. `process_cpu_seconds_total`).

When a `ProcessCollector` is registered and metrics are scraped via an HTTP endpoint, the output must include all of the following metrics (with the appropriate namespace prefix if set) and they must have parseable numeric values:

- `process_cpu_seconds_total` (a non-negative number; should look like a small integer/float)
- `process_max_fds` (an integer; typically at least two digits)
- `process_open_fds` (a positive integer)
- `process_virtual_memory_bytes` (a positive integer)
- `process_resident_memory_bytes` (a positive integer)
- `process_start_time_seconds` (a unix timestamp in seconds with fractional part allowed; should be large enough to look like a real epoch timestamp)

The collectors must be active by default in the library’s default registry behavior (i.e., standard exports should appear without requiring users to manually opt in), while still allowing manual registration in custom registries.

The implementation must use `/proc`-based process inspection when available; if the proc filesystem is not available, the behavior should degrade gracefully (e.g., avoid panics and allow the environment to skip/omit process metrics collection when unsupported).
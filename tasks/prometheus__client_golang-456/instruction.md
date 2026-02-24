The process metrics collector needs to be reworked to support best-effort collection without causing registry-wide failures, while still allowing callers to opt into error reporting.

Currently, using a process collector in a registry that must remain reliable (notably the DefaultRegistry) is problematic because failures to read process info (e.g., procfs errors, PID lookup failures) can surface as collection/gather errors and make the whole scrape fail. In practice, the process collector is often optional, so by default it should not report errors in a way that breaks collection.

Implement a single constructor `NewProcessCollector(opts ProcessCollectorOpts)` that replaces/absorbs the existing multiple constructors. The `ProcessCollectorOpts` must support:

- `PidFn func() (int, error)` to determine the PID to inspect. If unset, it must default to a function equivalent to `os.Getpid` (returning the current process PID without error).
- `Namespace string` to prefix metric names (empty string by default).
- `ReportErrors bool` controlling whether failures are exposed as error metrics. The default must be `false` so that process collection failures do not produce error metrics or cause collection/gather failures.

Behavior requirements:

- When `NewProcessCollector(ProcessCollectorOpts{})` is registered and gathered on a system where procfs is available, it must successfully expose the usual process metrics (e.g., CPU seconds total, open/max fds, virtual/resident memory, start time).
- When `Namespace` is set (e.g., `"foobar"`), the same metrics must be exposed with the namespace prefix (e.g., `foobar_process_cpu_seconds_total`, etc.).
- When `PidFn` returns an error and `ReportErrors` is `true`, the collector must still emit metrics, but those metrics must clearly report the error condition via the collector’s error-reporting mechanism (i.e., metrics written from `Collect` should reflect an error rather than silently succeeding). When `ReportErrors` is `false` (default), the same failure must not surface as error-reporting metrics and must not make registry gathering fail.
- The process collector should use const metrics (i.e., metrics whose descriptors are fixed and whose values are provided at collection time) rather than dynamically created metric descriptors per scrape.

The end result should allow applications to register the process collector as best-effort by default (no disruptive errors), while still enabling strict error visibility when `ReportErrors` is explicitly enabled.
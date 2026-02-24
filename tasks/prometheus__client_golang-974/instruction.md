In v1.12.0, the Go collector started exporting extremely granular histogram metrics derived from Go’s runtime/metrics package (notably in Go 1.17). This unexpectedly increases metric cardinality significantly compared to v1.11, which can cause operational issues for users running many Go services.

The Go collector should reduce the number of exported time series produced from runtime/metrics histograms for Go 1.17 by using coarser, exponential bucket boundaries for histograms whose unit is "seconds" or "bytes". The goal is to dramatically reduce the number of buckets (and therefore distinct Prometheus time series) without breaking the ability to collect the runtime/metrics set.

When collecting Go runtime metrics via the Go collector, all expected runtime/metrics entries must still be exposed under their corresponding Prometheus metric names (for example, "/gc/heap/allocs-by-size:bytes" must map to "go_gc_heap_allocs_by_size_bytes_total", and "/sched/latencies:seconds" must map to "go_sched_latencies_seconds"). However, the histogram series produced for these metrics must not explode in count due to overly fine bucket granularity.

Additionally, the collector should provide a stable cardinality expectation for Go 1.17 runtime/metrics collection: the total number of exported time series derived from the expected runtime/metrics set should match the known expected cardinality (79). If the runtime/metrics translation would produce more (or fewer) series, it should be treated as a regression because it indicates an unexpected cardinality change.

The following behavior should hold:

- Collecting metrics from the Go collector on Go 1.17 must still produce non-empty output and continue to include the expected runtime/metrics-derived metrics.
- Histogram metrics originating from runtime/metrics with unit "seconds" or "bytes" must be bucketed exponentially (coarser buckets) rather than using the original extremely granular bucket set.
- The overall number of emitted time series for the expected runtime/metrics set must be stable and equal to 79.
- Legacy memory metrics that overlap between the old memstats-based metrics and the runtime/metrics-based metrics must continue to match in value when both are exported (e.g., total system bytes and total allocation bytes should not diverge between the legacy and runtime/metrics variants).
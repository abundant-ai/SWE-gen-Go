On Linux systems where procfs is available, the process metrics collector should additionally expose per-process network I/O byte counters.

When registering a collector created by `NewProcessCollector(ProcessCollectorOpts{})` and gathering metrics from a registry, the output should include two new counter metrics:

- `process_network_receive_bytes_total`
- `process_network_transmit_bytes_total`

Both metrics must have numeric (non-negative) values and represent the total number of bytes received/transmitted by the current process as reported by procfs.

The same must work when using `NewProcessCollector(ProcessCollectorOpts{PidFn: func() (int, error) { return os.Getpid(), nil }, Namespace: "foobar", ReportErrors: true})`: in that case the metric names must be prefixed with the namespace, i.e. `foobar_process_network_receive_bytes_total` and `foobar_process_network_transmit_bytes_total`, and they should gather successfully without emitting any error metrics.

If procfs is not available on the running system, collection should behave as it does today (i.e., the collector should not crash); on systems with procfs, gathering must reliably include the new network byte counters alongside existing process metrics like CPU time, memory usage, file descriptor counts, and start time.
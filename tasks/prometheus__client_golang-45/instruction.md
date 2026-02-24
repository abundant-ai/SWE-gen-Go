Metrics collection currently has no structured way to report per-metric collection/encoding failures: if a metric cannot be written/encoded during a scrape, it typically results in a panic or aborts the entire scrape with an HTTP 500 (depending on configuration). At the same time, the public registration API is slightly awkward because Register() returns the Collector, even though callers generally only need an error result.

Implement two related interface/API changes:

1) Simplify registration: The function Register(...) should no longer return the registered Collector. It should only return an error indicating whether registration succeeded (or why it failed). Code that previously relied on the returned Collector should use RegisterOrGet(...) instead, which must continue returning the previously registered Collector when appropriate.

2) Allow error reporting during metrics collection without changing Collector.Collect/Describe signatures: The Metric interface must be updated so that Metric.Write(*dto.Metric) returns an error. Any existing Metric implementations (e.g., Gauges, Counters, and custom metrics built via SelfCollector) must conform to the new signature.

Additionally, there must be a way for a Collector to signal that a metric could not be collected by sending a special “invalid metric” value over the Metric channel. This invalid metric must carry the underlying error, and when its Write method is called it must return that error.

Expected behavior:
- Existing metric types’ Write methods should return nil on success.
- User-defined metrics that implement Write should be able to return a non-nil error to indicate failure.
- A collector should be able to emit an invalid metric into the collection stream to report a collection problem for a specific metric without changing the Collect/Describe method signatures.
- Calling code that encodes/exports metrics must handle Metric.Write returning an error and propagate/report it consistently (e.g., turning the scrape into an error response or triggering the configured error behavior), rather than silently ignoring the failure.

Also ensure that common usage continues to work unchanged aside from the signature updates, e.g.:
- MustRegister(m) successfully registers metrics.
- Collectors like NewGoCollector() can still Collect into a channel and produced metrics can be written into a dto.Metric.
- Register(gaugeFunc) continues to return an error only; example code that previously checked `if err := Register(...); err == nil { ... }` must still compile and behave the same (except it no longer can use a returned Collector from Register).
Prometheus metric exposition currently assumes that a call to Gather() returns a fully materialized snapshot of metric families. This makes it hard for instrumentations that want to reuse cached/aggregated results efficiently and safely, because there is no standardized way to associate a “lifecycle” with a gather operation (e.g., keep a cache entry pinned until the HTTP response is fully produced, then release it).

Implement support for a transactional gather pattern in the client library so that metric exposition can use cached solutions without races or premature cache invalidation.

Introduce and wire up a gatherer API that can return both the gathered metric families and a completion callback. The key behavior is:

When calling a transactional gatherer’s Gather(), it returns (1) the []*dto.MetricFamily snapshot to expose, (2) a done() function to be called exactly once when the caller is finished with the snapshot, and (3) an error.

Update the HTTP handler API to support this lifecycle explicitly via HandlerForTransactional(...). When serving /metrics using a transactional gatherer:

- The handler must invoke the transactional Gather() once per scrape.
- The handler must ensure the returned done() is called exactly once for that scrape, even if the handler exits early due to encoding errors, request context cancellation, client disconnect, or when using an error handling mode that responds with an HTTP error.
- The handler must preserve existing error-handling semantics (e.g., ContinueOnError vs HTTPErrorOnError) while still guaranteeing done() is eventually called.

Additionally, ensure that transactional gathering composes correctly with existing registerer/registry behavior so that:

- Existing non-transactional gatherers continue to work unchanged.
- A transactional gatherer can wrap an existing prometheus.Gatherer and reliably observe that done() is invoked after the exposition is finished.

A concrete scenario that must work is a wrapper gatherer (e.g., mockTransactionGatherer) that increments a counter each time Gather() is invoked and increments another counter when its done() callback is invoked. After a scrape is served through HandlerForTransactional, both counters should reflect that the handler called Gather() once and later called done() once, including in error cases where metric collection reports an error and the handler is configured to return an HTTP error response.

The goal is to make it safe for callers to implement caching/aggregation strategies that require a deterministic end-of-scrape notification, enabling high-cardinality/expensive metric producers to expose cheaper aggregated metrics or cached snapshots without leaking resources or returning inconsistent results.
When exporting metrics in Prometheus protobuf format, Counters, Summaries, and Histograms should include a creation timestamp so that downstream systems can distinguish newly-created one-sample time series from long-lived series (improving correctness of rate-like calculations and handling of high-churn series).

Currently, when a Counter, Summary, or Histogram is created and then exported via protobuf, the resulting dto.Metric does not consistently populate the `CreatedTimestamp` field on the corresponding metric message (`dto.Counter.CreatedTimestamp`, `dto.Summary.CreatedTimestamp`, `dto.Histogram.CreatedTimestamp`). This makes it impossible for consumers to know when the time series began, which is particularly problematic for ephemeral series that may only ever emit a single sample.

Implement support for creation timestamps across these metric types so that:

- When a Counter is exported to protobuf, `dto.Metric.Counter.CreatedTimestamp` is set to the metric’s creation time.
- When a Summary is exported to protobuf, `dto.Metric.Summary.CreatedTimestamp` is set to the metric’s creation time.
- When a Histogram is exported to protobuf, `dto.Metric.Histogram.CreatedTimestamp` is set to the metric’s creation time.

Additionally, provide a way to create a const metric with an explicit creation timestamp:

- Implement `NewConstMetricWithCreatedTimestamp(desc *Desc, valueType ValueType, value float64, createdTimestamp time.Time) (Metric, error)`.
- `NewConstMetricWithCreatedTimestamp` must reject unsupported metric types for creation timestamps. In particular, attempting to use it with `GaugeValue` must return an error (creation timestamp must not be set for gauges).
- When called with `CounterValue` and a valid timestamp, writing the returned metric into a `dto.Metric` must yield a counter whose `CreatedTimestamp` matches the provided `createdTimestamp` (as a protobuf `timestamppb.Timestamp`).

The behavior should be consistent across collection/export paths so that metrics created via the usual Counter/Summary/Histogram constructors, as well as const metrics created via `NewConstMetricWithCreatedTimestamp`, all correctly populate `CreatedTimestamp` in the protobuf representation when applicable.
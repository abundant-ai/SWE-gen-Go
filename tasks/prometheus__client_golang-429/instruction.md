Registering Prometheus metrics currently allows invalid combinations involving Summaries and Histograms that implicitly create additional time series. A Summary named `xxx` implicitly creates `xxx_count` and `xxx_sum`. A Histogram named `xxx` implicitly creates `xxx_count`, `xxx_sum`, and `xxx_bucket`. Because these series names are derived automatically, users can accidentally (or intentionally) register other metrics with those derived names, creating collisions that should be rejected.

The registry must detect and reject these name collisions both ways:

- If a Summary is registered with name `xxx`, then attempting to register any other metric with name `xxx_count` or `xxx_sum` must fail.
- If a Histogram is registered with name `xxx`, then attempting to register any other metric with name `xxx_count`, `xxx_sum`, or `xxx_bucket` must fail.
- Conversely, if any metric is registered with name `xxx_count` or `xxx_sum`, then later registering a Summary or Histogram with base name `xxx` must fail.
- If any metric is registered with name `xxx_bucket`, then later registering a Histogram with base name `xxx` must fail.

Additionally, Summaries must continue to reject usage of the reserved label name `quantile`: creating a `Summary` with a constant label named `quantile`, or creating a `SummaryVec` with `quantile` as a variable label, must panic.

The failure mode for rejected registrations should be an error returned from `Register`/`Registry.Register` (and `MustRegister` should still panic on that error). After implementing the collision detection, gathering metrics from a registry should not produce ambiguous/duplicated metric families arising from these implicit suffix collisions.
Constant histograms created via MustNewConstHistogram/NewConstHistogram cannot currently carry exemplars through to the emitted Prometheus DTO metric. This is a problem for pipelines that ingest histogram data from external systems (e.g., OpenTelemetry Collector exporters) and need to convert it to Prometheus metrics while retaining exemplar information.

When creating a constant histogram from pre-aggregated bucket counts and then wrapping it with exemplar data (via a metric wrapper that injects exemplars into the written DTO), exemplars should be attached to the appropriate histogram buckets when the metric is serialized (i.e., when Write(*dto.Metric) is called). Right now, exemplars are not being set correctly for const histogram buckets, so consumers do not see exemplar data on the resulting histogram buckets.

Implement exemplar support for constant histograms so that calling Write on a const histogram metric (including when wrapped by a helper like withExemplarsMetric) results in histogram buckets that include exemplar data. Exemplars must be assigned to buckets based on the exemplar’s Value relative to the bucket upper bounds.

Required behavior:
- A const histogram created with cumulative bucket counts for upper bounds (e.g., 25, 50, 100, 200) must emit exactly those buckets.
- Given a list of exemplars (each with a Value) provided alongside the metric, Write(*dto.Metric) must attach an exemplar to each bucket when an appropriate exemplar value exists for that bucket.
- Exemplars must be matched to buckets by value:
  - A value less than or equal to a bucket’s upper bound belongs to that bucket.
  - If multiple exemplars would fall into the same bucket, the behavior should be deterministic; the expected outcome is that one exemplar is selected per bucket.
- Example scenario to satisfy:
  - Histogram buckets with upper bounds: 25, 50, 100, 200
  - Exemplars with values: 24.0, 25.1, 42.0, 89.0, 100.0, 157.0
  - After Write, the four emitted buckets must have non-nil exemplars with exemplar values: 24.0 for <=25, 42.0 for <=50, 100.0 for <=100, and 157.0 for <=200.

The end result should allow external systems to export const histograms with exemplars preserved in the Prometheus metric representation without needing to re-observe samples into a live histogram.
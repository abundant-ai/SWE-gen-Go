Prometheus text and protobuf metric handling currently lack support for the histogram metric type in key ingestion and exposition paths. As a result, metric families of type HISTOGRAM cannot be reliably parsed from the Prometheus text exposition format, converted into the expected internal sample representation for extraction/ingestion, or rendered back to text.

Implement end-to-end support for histograms in the existing tooling:

1) Text format parsing
When using the text parser (via the existing Parser API) to parse input containing:
- a `# TYPE <name> histogram` directive, and
- histogram series that use the conventional suffixes and labels:
  - `<name>_bucket{...,le="<upper_bound>"} <count>` for each bucket (including `le="+Inf"`),
  - `<name>_sum{...} <sum>`,
  - `<name>_count{...} <count>`,

…the parser should produce a `dto.MetricFamily` with:
- `Type` set to `dto.MetricType_HISTOGRAM`, and
- each `dto.Metric` containing a populated `Histogram` field with:
  - `SampleCount` matching `<name>_count`,
  - `SampleSum` matching `<name>_sum`,
  - `Bucket` entries derived from the `_bucket` series.

Bucket handling requirements:
- Buckets must be ordered by increasing `UpperBound`.
- The `CumulativeCount` for each bucket must correspond to the value of the matching `_bucket{le=...}` series.
- `le` must be parsed as a float upper bound, supporting `+Inf`.
- Histogram series must be associated correctly by matching metric name base (`<name>`) and matching all labels other than `le` (i.e., `le` is a bucket discriminator, not a histogram identity label).

2) Text format creation
When serializing a histogram `dto.MetricFamily` to the Prometheus text exposition format (using the existing creation API), the output must follow the canonical form:
- Emit `# HELP` and `# TYPE` lines with `histogram`.
- For each histogram metric, emit:
  - one line per bucket as `<name>_bucket{<labels>,le="..."} <cumulative_count>`
  - one `_sum` line
  - one `_count` line

Formatting requirements:
- `le` must be formatted as a quoted label value; `+Inf` must be rendered as `+Inf`.
- The label set on bucket lines must include all original metric labels plus the `le` label.
- `_sum` and `_count` must use the original metric labels (no `le`).
- Any timestamp present on the `dto.Metric` must be rendered on each emitted line consistently with existing behavior for other metric types.

3) Extraction / metric family processing to samples
When processing a protobuf metric family containing histograms through the metric family processor (via `MetricFamilyProcessor.ProcessSingle` and the `ProcessOptions` timestamp handling), histogram metrics must be converted into the appropriate set of `model.Sample` values for ingestion.

Specifically, for each histogram metric, produce samples equivalent to what the text format would represent:
- One sample per bucket, using metric name `<base>_bucket` and including the `le` label.
- One sample for `<base>_sum`.
- One sample for `<base>_count`.

All generated samples must:
- include the original metric labels (and `le` where applicable),
- use the value from the histogram fields/buckets,
- use the timestamp provided by `ProcessOptions.Timestamp` when present (consistent with other metric types).

The current behavior either ignores histograms, misclassifies them as untyped, or fails to group bucket/sum/count into a single histogram structure. After implementing the above, histograms should round-trip through parse -> protobuf -> create, and they should be extractable into the correct sample series without errors.
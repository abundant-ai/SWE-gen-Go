String formatting for Prometheus model label collections is inconsistent with Prometheus server behavior, causing mismatches in rendered metric/label output and leading to downstream failures where stable textual representations are expected.

The types involved are:
- model.LabelSet
- model.Metric

Both types have a String() method that should produce a deterministic, Prometheus-compatible textual representation. Currently, the output differs from what Prometheus server produces (ordering/escaping/format details), which results in unstable or incorrect strings when metrics/labels are rendered.

Update model.LabelSet.String() and model.Metric.String() so that:
- Output is deterministic across runs (no dependence on Go map iteration order).
- Label pairs are rendered in a stable, canonical order.
- The formatting matches Prometheus’s conventional text form for labels/metrics (including correct quoting/escaping of label values).
- For model.Metric.String(), the metric name and its label set are rendered consistently (metric name first, labels in canonical form).

This impacts the extraction processors that consume JSON input and produce samples with metrics and labels. After the change, the processors should still produce the same metric/label content, and any string rendering of those structures (including in error/debug output and comparisons) should match the canonical Prometheus server behavior.

Also ensure JSON decoding error reporting remains correct for the supported processor versions: when processing empty/invalid JSON input, the returned error message should match the expected Go JSON decoder error for that processing path (e.g., distinguishing between errors like "unexpected end of JSON input" vs "EOF" as appropriate for the versioned processor behavior).
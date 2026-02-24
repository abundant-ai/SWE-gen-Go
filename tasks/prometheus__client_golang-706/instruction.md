Counters and histograms currently cannot attach Prometheus exemplars to observations/increments, so users cannot emit exemplar data (labels + timestamp) alongside counter values or histogram bucket observations.

Implement exemplar support for both Counter and Histogram so that users can record an exemplar at the time they add/increment a counter or observe a histogram. When a metric is written out into a dto.Metric (protobuf), the exemplar must be included in the exported representation.

For counters:
- Provide a way to increment/add to a counter while also supplying an exemplar (exemplar label set and optional timestamp).
- The counter’s Write(*dto.Metric) output must include the exemplar data in the protobuf (so that, after increments/additions with exemplars, the exported metric contains an exemplar attached to the counter sample).
- Existing counter behavior must remain unchanged when no exemplar is provided (value accounting and monotonicity checks still apply; adding a negative value must still fail with the same panic/error behavior as before).

For histograms:
- Provide a way to Observe a value while also supplying an exemplar.
- The histogram’s Write(*dto.Metric) output must include exemplars on the appropriate bucket(s) in the protobuf. An exemplar recorded with an observation should be attached to the bucket that the observation falls into (i.e., the first bucket boundary that is >= the observed value).
- Histogram semantics must remain correct (bucket counts, sum, and +Inf bucket handling must be unaffected by exemplars; invalid bucket definitions must still panic as before).

Exemplar details:
- Exemplars consist of a set of labels and a timestamp. They must be encoded in the dto.Metric output using the exemplar fields defined by the Prometheus client model.
- If multiple observations/increments happen with exemplars, the most recent exemplar for a given target (counter sample, or a specific histogram bucket) should be the one exported.
- Exemplar label values must follow the same general constraints as metric label values (e.g., must be valid UTF-8). Invalid exemplar labels should result in a failure consistent with existing label validation behavior.

After implementing, calling the new exemplar-enabled methods and then calling Write on the metric should produce a dto.Metric whose String() representation includes the exemplar(s) in the appropriate place, and existing non-exemplar operations must continue to match prior output exactly.
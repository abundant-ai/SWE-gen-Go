Two related behaviors in the Prometheus Go client library are incorrect and need to be fixed.

1) Exemplars attached to histogram buckets are not reliably assigned to the correct bucket.
When a metric is wrapped to inject exemplars (via a metric wrapper that writes a DTO metric and populates exemplars), providing a set of histogram exemplars in arbitrary order should still result in each histogram bucket containing the exemplar that belongs to that bucket. Exemplars must be matched to the correct histogram bucket based on the exemplar’s value relative to bucket upper bounds, not by insertion order.

Repro scenario: create a constant histogram metric (e.g., via MustNewConstHistogram) with explicit bucket upper bounds and counts, then wrap it in a metric type that adds exemplars (e.g., withExemplarsMetric) and call Write(*dto.Metric). If the provided exemplars are unordered, the resulting dto.Metric’s histogram buckets should still:
- include the expected number of buckets, including an automatically created +Inf bucket when needed
- have a non-nil Exemplar for each bucket that receives one
- assign exemplar values to buckets consistently according to their numeric value (e.g., values <= 25 go to the 25 bucket, values between 25 and 50 go to the 50 bucket, etc.), rather than shifting exemplars to the wrong buckets.

Currently, unordered exemplars can end up attached to the wrong bucket (or missing), producing incorrect exemplar values per bucket after Write().

2) promhttp instrumented HTTP client metrics are inconsistent in label handling and/or produced metric output.
When using the instrumented client helpers (e.g., InstrumentRoundTripperInFlight, InstrumentRoundTripperCounter, InstrumentRoundTripperTrace, InstrumentRoundTripperDuration) to wrap an http.RoundTripper, the emitted metrics (counters and histograms) must be label-consistent and deterministic so that scraping/collection yields stable label sets and correct samples.

Repro scenario: construct an instrumented http.Client with these wrappers and perform HTTP requests against a test server. The registry metrics should reflect:
- correct request counting by HTTP status code and method
- correct duration histogram observations by method
- correct trace histogram observations (DNS and TLS events)
- correct in-flight gauge behavior

Currently, the instrumented client path has a bug that causes metric label pairs and/or recorded samples to be incorrect or unstable (e.g., unexpected/missing labels, wrong label ordering leading to mismatches when comparing gathered metrics, or incorrect attribution of observations).

Fix the implementation so that:
- Histogram exemplars are bucket-matched by value and consistently attached during Write().
- Instrumented client metrics have correct, stable labels and values across requests when using the promhttp instrumentation wrappers and options.
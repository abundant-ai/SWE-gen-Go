When using metric vectors (e.g., GaugeVec/CounterVec/etc.) with labels, the client returns an “inconsistent cardinality” error when the number of provided label values doesn’t match the number of variable labels defined for the metric. Currently, this error message is too generic and does not contain enough context to identify where the mismatch came from.

Improve the inconsistent-cardinality error reporting so that the returned error includes additional identifying information about the metric and the attempted operation. In particular, the error should include the metric’s fully-qualified name and should show the label values that were provided (and, where applicable, the expected label names / expected cardinality vs. actual).

Example scenario:
- A vector is created with two variable labels, e.g. NewGaugeVec(..., []string{"user", "type"}).
- A caller then uses WithLabelValues("bob") (only one value).

Expected behavior: the call should still fail with an inconsistent-cardinality error, but the error text must clearly indicate:
- which metric triggered the error (metric name),
- what label values were supplied (e.g., ["bob"]),
- what was expected vs what was provided (e.g., expected 2 values for labels ["user" "type"], got 1).

Actual behavior: the error lacks this contextual information, making it hard to trace the source of the mismatch.

Update the library so that any inconsistent-cardinality errors produced by vector label accessors (e.g., WithLabelValues / With) carry this additional context consistently.
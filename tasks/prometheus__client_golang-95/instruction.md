Two correctness bugs exist in the Summary metric implementation.

1) Concurrency safety: Under concurrent use, calling Summary.Observe(...) from multiple goroutines while other goroutines call Summary.Write(...) can lead to incorrect results and/or data races. Summary is expected to be safe for concurrent Observe and Write calls, and when used concurrently it must produce a consistent Metric output (count, sum, and quantile samples) equivalent to what would be produced if all observations were applied and then written.

In particular, when many goroutines concurrently add observations, the exported Metric must still reflect:
- SampleCount equal to the total number of observations
- SampleSum equal (within normal floating point tolerance) to the sum of all observed values
- Quantile outputs consistent with the configured objectives (or default behavior), and never containing invalid values (e.g., NaN where not expected).

2) Summary output correctness: The data exported by Summary.Write(...) has edge cases where it can be wrong even without triggering a panic. When a Summary is observed heavily and then written repeatedly (including from multiple goroutines), the produced dto.Metric must always be internally consistent: SampleCount and SampleSum must match the observations applied, and the quantile list must be stable and correctly ordered by quantile.

The fix should ensure that Summary.Observe and Summary.Write behave correctly and deterministically under high concurrency, and that repeated calls to Write do not mutate shared state in a way that corrupts future exports.
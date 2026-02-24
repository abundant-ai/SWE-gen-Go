Processors in the extraction pipeline expose a single-item processing API (e.g., `ProcessSingle`) that decodes an input stream into one or more `Result` values and forwards each `Result` to a downstream consumer via an `Ingest(*Result) error` method.

Currently, chaining multiple processors together is awkward because the consumer contract forces callers to manage channels or otherwise adapt between stages. The consumer signature needs to be updated so processors can be composed directly (processor output feeding another processor) without callers needing to manually wire channels.

Update the consumer contract used by `MetricFamilyProcessor.ProcessSingle`, `Processor001.ProcessSingle`, and `Processor002.ProcessSingle` so that a consumer can be implemented by a simple struct that collects results and returns an error, while also supporting chaining to another processor stage.

After the change:
- Calling `ProcessSingle(reader, consumer, options)` must still iterate over all decoded metric families/samples and forward them in order by invoking the consumer’s ingestion method.
- A consumer implementation that appends received `*Result` values to a slice (e.g., `actual = append(actual, r)`) must receive exactly the expected number of results, and each `Result` must contain the expected `Samples` with the provided `ProcessOptions.Timestamp` applied.
- Errors from the underlying decoder/parsing must be returned unchanged by `ProcessSingle`. For example, processing invalid/empty JSON input must still surface errors like `"unexpected end of JSON input"` and `"EOF"` (depending on processor/version) rather than being wrapped or swallowed.
- The updated consumer signature must not require users to create or manage channels to connect processors; it should be possible to build a pipeline where the output consumer of one processor can directly feed the next stage.

The end result should preserve existing processing semantics (same decoded samples, labels, and timestamps) while changing the ingestion/consumer API so processor chaining is straightforward and channel-free for callers.
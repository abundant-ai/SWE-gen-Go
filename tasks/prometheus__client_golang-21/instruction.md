The extraction API needs to support ingesting telemetry streams encoded as Protocol Buffer messages in addition to the existing JSON-based formats. Currently, requests with a Protocol Buffer Content-Type are not correctly recognized and/or cannot be decoded into samples.

Implement support for selecting and running a Protocol Buffer processor based on HTTP request headers, and ensure MetricFamily Protocol Buffer payloads can be decoded into sample results.

When determining the processor from headers, calling `ProcessorForRequestHeader(header)` must behave as follows:
- If `header` is nil or otherwise illegal, return an error with the message: `Received illegal and nil header.`
- For JSON Content-Types with an API version, unsupported versions must return an error `Unrecognized API version <version>`, while supported versions must return the correct processor:
  - `Content-Type: application/json` with `X-Prometheus-API-Version: 0.0.1` must select `Processor001`.
  - `Content-Type: application/json; schema="prometheus/telemetry"; version=0.0.1` must select `Processor001`.
  - `Content-Type: application/json; schema="prometheus/telemetry"; version=0.0.2` must select `Processor002`.
- For Protocol Buffer Content-Types, it must parse the `proto` and `encoding` parameters and select the correct processor or return specific errors:
  - `Content-Type: application/vnd.google.protobuf; proto="io.prometheus.client.MetricFamily"; encoding="varint record length-delimited"` must select `MetricFamilyProcessor`.
  - If `proto` is not recognized (e.g. `proto="illegal"`), return `Unrecognized Protocol Message illegal`.
  - If `encoding` is not supported (e.g. `encoding="illegal"`), return `Unsupported Encoding illegal`.

Also implement decoding for the selected processor:
- `MetricFamilyProcessor` must implement `ProcessSingle(reader, resultsChan, options)` such that it can read a stream of length-delimited Protocol Buffer `io.prometheus.client.MetricFamily` messages (using varint record length-delimited encoding) and emit `*Result` values containing decoded `model.Samples`.
- Decoding an empty input must succeed (no error) and produce no results.
- For valid MetricFamily inputs, it must emit samples that:
  - Use `options.Timestamp` as the timestamp for produced samples.
  - Merge `options.BaseLabels` into each sample’s metric labels.
  - Set the metric name label to the MetricFamily name (e.g. `name: "request_count"`).
  - Include label pairs from each metric within the family (e.g. `some_label_name: some_label_value`).
  - Correctly decode values for different metric types (at least counters, gauges, and summaries) into the appropriate sample values and associated label sets.

The overall goal is that a request using the Protocol Buffer Content-Type for MetricFamily streams is properly recognized by `ProcessorForRequestHeader` and successfully decoded by `MetricFamilyProcessor.ProcessSingle` into the same internal result/sample representation as other supported formats, while returning the exact error messages above for unsupported `proto` or `encoding` values.
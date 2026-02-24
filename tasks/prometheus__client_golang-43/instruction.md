The extraction processors currently rely on an intermediate “extraction result” type when parsing and ingesting samples. This extra result layer is being removed, but the behavior of the public processing entrypoints must remain unchanged.

When using the various processors’ single-pass APIs (e.g., calling `ProcessSingle` on processors like `Processor004`, `Processor001`, and `MetricFamilyProcessor`) with an `io.Reader`, an ingester that implements `Ingest(model.Samples) error`, and `ProcessOptions{Timestamp: <ts>}`, the processors must ingest the same `model.Samples` groups as before.

In particular:

- `Processor004.ProcessSingle(reader, ingester, options)` must parse text-format metric families and call `ingester.Ingest(...)` once per metric name (metric family), passing a `model.Samples` slice containing all samples for that metric name. For samples without an explicit timestamp in the input, the timestamp must be set to `options.Timestamp`. For samples with an explicit timestamp in the input, that timestamp must be preserved.

- `MetricFamilyProcessor.ProcessSingle(reader, ingester, options)` must decode metric family payloads and ingest the expected grouped `model.Samples`. It must apply `options.Timestamp` consistently where timestamps are not provided by the input encoding.

- `Processor001.ProcessSingle(reader, ingester, options)` must continue to return the same parsing/decoding errors for invalid inputs. For example, when the input is empty/invalid JSON, the returned error must match `unexpected end of JSON input`.

The removal of the extraction result type must not change:

- how many times `Ingest` is called for a given input,
- how samples are grouped into each `model.Samples` passed to `Ingest`,
- metric names/labels/values produced for each sample,
- and timestamp handling (explicit timestamps preserved; missing timestamps filled with `ProcessOptions.Timestamp`).

After the refactor, all processors should still be usable via the same `ProcessSingle` methods and produce identical ingested `model.Samples` content and error behavior as before.
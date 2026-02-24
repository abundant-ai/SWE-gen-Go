Several small but user-visible inconsistencies exist across the Go client’s collectors and API client utilities.

1) Process metrics naming/prefixing is inconsistent when using the process collector with a namespace.

When creating a process collector via NewProcessCollectorPIDFn(pidFn, namespace) with a non-empty namespace (e.g., "foobar"), all exported process metrics should be consistently prefixed with that namespace. For example, if the default collector exports:
- process_cpu_seconds_total
- process_max_fds
- process_open_fds
- process_virtual_memory_bytes
- process_resident_memory_bytes
- process_start_time_seconds

then a collector created with namespace "foobar" should export the corresponding metrics as:
- foobar_process_cpu_seconds_total
- foobar_process_max_fds
- foobar_process_open_fds
- foobar_process_virtual_memory_bytes
- foobar_process_resident_memory_bytes
- foobar_process_start_time_seconds

Currently, at least one of these metrics is missing, incorrectly named, or not consistently prefixed when a namespace is provided. Gathering from a registry that has both a default process collector and a namespaced one should yield both sets of metrics with the expected names.

2) API client URL construction produces incorrect URLs for certain combinations of base address, endpoint paths, and path parameters.

The method httpClient.URL(endpoint string, args map[string]string) should build correct URLs with these behaviors:
- Joining base address and endpoint should not introduce double slashes, and trailing slashes should be normalized (e.g., base "https://localhost:9090/" + endpoint "/test/" should become "https://localhost:9090/test").
- If the base address includes a path prefix (e.g., "http://localhost:9090/prefix"), the endpoint should be appended under that prefix (e.g., endpoint "/test" → "http://localhost:9090/prefix/test").
- Endpoints may contain placeholders of the form ":param". If args contains a matching key, all occurrences of that placeholder must be replaced (e.g., "/test/:param/more/:param" with param=content → "/test/content/more/content").
- If args does not contain a matching key for a placeholder, that placeholder must remain unchanged in the returned URL (e.g., endpoint "/test/:param" with args {"nonexistent":"content"} should remain "/test/:param").

At the moment, at least one of these cases yields an incorrect URL string (such as incorrect slash normalization, incorrect prefix handling, or incomplete placeholder replacement).

3) Config should reliably use the default HTTP RoundTripper when none is provided.

When Config.RoundTripper is nil, Config.roundTripper() must return DefaultRoundTripper. Currently, Config.roundTripper() may return a nil or non-default transport, which breaks the expectation that a default transport is always used unless explicitly overridden.

The fix should ensure that: (a) the namespaced process collector emits a full, consistently prefixed metric set; (b) httpClient.URL returns the correct URL strings for the path-joining and placeholder scenarios described above; and (c) Config.roundTripper() returns DefaultRoundTripper when the RoundTripper field is nil.
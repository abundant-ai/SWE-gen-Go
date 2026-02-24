Bucket object listings can stop early when an ILM (lifecycle expiration) policy is enabled and the client requests a bounded page size (for example via the S3 ListObjects/ListObjectsV2 `max-keys` parameter). During lifecycle processing, some objects are skipped/filtered out, and the listing response may incorrectly indicate that the listing is complete.

When calling S3 listing APIs with `max-keys` set (typical clients always send it), the server should return up to `max-keys` eligible results for that page and set `IsTruncated`/`IsTruncated`-equivalent correctly (true when there are more eligible entries to list, false only when the listing has truly been exhausted). If objects are skipped due to ILM/lifecycle evaluation, the server must not treat “fewer than max-keys returned” as proof that there are no more entries; it must continue scanning underlying storage until it can confidently determine whether more eligible items exist or until the request is terminated.

Current incorrect behavior: while lifecycle expiration/cleaning is running (or when lifecycle rules cause objects to be skipped), repeated listings of the same bucket can suddenly return dramatically fewer items than expected and may report the listing as not truncated even though many more objects still exist. This presents as unreliable/incomplete bucket listings during ILM activity.

Implement/fix the listing flow so that `max-keys` does not cause the underlying directory/object walkers to stop producing entries prematurely when filtering (ILM/lifecycle) is in effect. The walker/drive enumeration should keep feeding candidates until either:

- enough eligible entries have been found to satisfy `max-keys`, in which case the response is truncated as appropriate and a continuation marker/next token is provided, or
- the backend is truly exhausted (no more entries across drives), in which case `IsTruncated` must be false.

The listing must be stoppable promptly via request context cancellation once the server has gathered enough results (or the client disconnects), rather than relying on the walker stopping purely due to `max-keys` when filtered/skipped entries are present.

This should work for versioned buckets and listings involving folder-like prefixes as well, ensuring listings remain consistent and do not end early solely because some entries are excluded by lifecycle/ILM logic.
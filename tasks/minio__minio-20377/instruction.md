MinIO’s queue store currently persists notification events one-by-one, which causes excessive IO when targets are down or slow. For Kafka notifications, events should be buffered per target and written to the queue store as a single batch when the configured batch size is reached, and any remaining buffered events should also be committed periodically based on a configurable commit timeout (default 30s). Additionally, when batching writes to the queue store, the stored payload should support compression for multi-write batches, and stored object keys must encode both the item count and whether compression was used.

Implement batched queue-store commits for Kafka notification such that:

When the Kafka target is unavailable and events are generated, the events are accumulated in-memory per target. The queue store should remain unchanged until the batch limit is hit (no files/keys created before the batch is full).

When adding an event causes the batch to exceed the configured limit, the previous full batch must be committed to the queue store as a single entry, and the new event begins the next batch. After this happens, the in-memory batch length should reset to 1, and the queue store should contain exactly one new key representing the committed batch.

The queue store must be able to write and read multiple items in a single stored entry. Reading back a batch entry must return exactly the number of items that were committed.

Queue store keys must round-trip correctly via string formatting/parsing:
- A non-batched (single item) key should serialize as: <uuid><extension>
- A batched key should serialize as: <count>:<uuid><extension>
- If the stored entry is compressed, the key should include the ".snappy" suffix.
- If count is 1, the count prefix must be omitted (even if compression is enabled).
Parsing must reconstruct: Name, Extension, ItemCount (default 1), and Compress.

Batched entries written by the batcher should set the key metadata so that:
- key.ItemCount equals the batch size committed
- key.Compress is true for committed batches (multi-item writes)

The batcher must also flush any pending items when it is closed/shutdown, committing the remaining items to the queue store even if the batch is not full.

Finally, the batcher must support periodic flush based on CommitTimeout: if the batch has pending items and the timeout elapses, it should commit the pending items to the queue store.

The public API surface involved should include the queue store’s ability to store and retrieve multiple items (e.g., a method like GetMultiple(key) for reading a batched entry) and a batching component constructed with a configuration including Limit, Store, CommitTimeout, and a Log callback. Calling Add(item) should add to the batch and trigger commits as described, Len() should report the current in-memory batch size, and Close() should flush outstanding items.

Expected behavior summary: enabling Kafka notifications with a batch size should result in fewer queue-store entries when the target is down (each entry representing many events), those entries should be replayable in batches when the target comes back, and the queue store should eventually drain to empty after successful replay.
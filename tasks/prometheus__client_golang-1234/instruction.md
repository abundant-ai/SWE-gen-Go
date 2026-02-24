When using this library with Go 1.20, the Go runtime metric set exposed via the Go collector is not handled correctly. Collecting runtime metrics should work on Go 1.20 and must expose the expected Prometheus metric names for all supported Go 1.20 runtime metrics.

Currently, on Go 1.20, mapping runtime metric names (e.g. runtime/metrics paths like "/cpu/classes/gc/mark/assist:cpu-seconds" and "/gc/heap/allocs:bytes") to Prometheus metric names is incomplete/incorrect, causing missing metrics and/or unexpected metric names from the Go collector.

Update the Go collector/runtime metrics support so that, on Go 1.20, the runtime metrics are exported with the correct Prometheus names and types. In particular, the runtime metric name to Prometheus metric name mapping must include the Go 1.20 metric set, producing names such as:

- go_cgo_go_to_c_calls_calls_total
- go_gc_cycles_automatic_gc_cycles_total
- go_gc_cycles_forced_gc_cycles_total
- go_gc_cycles_total_gc_cycles_total
- go_cpu_classes_gc_mark_assist_cpu_seconds_total
- go_cpu_classes_gc_mark_dedicated_cpu_seconds_total
- go_cpu_classes_gc_mark_idle_cpu_seconds_total
- go_cpu_classes_gc_pause_cpu_seconds_total
- go_cpu_classes_gc_total_cpu_seconds_total
- go_cpu_classes_idle_cpu_seconds_total
- go_cpu_classes_scavenge_assist_cpu_seconds_total
- go_cpu_classes_scavenge_background_cpu_seconds_total
- go_cpu_classes_scavenge_total_cpu_seconds_total
- go_cpu_classes_total_cpu_seconds_total
- go_cpu_classes_user_cpu_seconds_total
- go_gc_heap_allocs_by_size_bytes
- go_gc_heap_allocs_bytes_total
- go_gc_heap_allocs_objects_total
- go_gc_heap_frees_by_size_bytes
- go_gc_heap_frees_bytes_total
- go_gc_heap_frees_objects_total
- go_gc_heap_goal_bytes
- go_gc_heap_objects_objects
- go_gc_heap_tiny_allocs_objects_total
- go_gc_limiter_last_enabled_gc_cycle
- go_gc_pauses_seconds
- go_gc_stack_starting_size_bytes
- go_memory_classes_heap_free_bytes
- go_memory_classes_heap_objects_bytes
- go_memory_classes_heap_released_bytes
- go_memory_classes_heap_stacks_bytes
- go_memory_classes_heap_unused_bytes
- go_memory_classes_metadata_mcache_free_bytes
- go_memory_classes_metadata_mcache_inuse_bytes
- go_memory_classes_metadata_mspan_free_bytes
- go_memory_classes_metadata_mspan_inuse_bytes
- go_memory_classes_metadata_other_bytes
- go_memory_classes_os_stacks_bytes
- go_memory_classes_other_bytes
- go_memory_classes_profiling_buckets_bytes
- go_memory_classes_total_bytes
- go_sched_gomaxprocs_threads
- go_sched_goroutines_goroutines
- go_sched_latencies_seconds
- go_sync_mutex_wait_total_seconds_total

The implementation should ensure that the Go collector on Go 1.20 exports the full expected set (including base metrics and optional subsets such as GC-only metrics) and that the metric names are stable and consistent with the runtime/metrics descriptors for Go 1.20.
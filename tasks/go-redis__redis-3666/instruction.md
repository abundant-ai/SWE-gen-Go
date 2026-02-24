Connection pools currently allow configuring `ConnMaxLifetime`, but when many connections are created around the same time they also tend to expire around the same time. This can cause a “thundering herd” of reconnects where a large number of connections become stale simultaneously, leading to load spikes.

Add support for a new configuration value `ConnMaxLifetimeJitter time.Duration` that randomizes (jitters) per-connection expiration times around the configured `ConnMaxLifetime`.

The new option must be available anywhere connection options are exposed, including `Options` used by `NewClient`, failover/sentinel options used by `NewFailoverClient`, and the option types used by ring, universal, and cluster clients. Setting `ConnMaxLifetimeJitter` should influence how the pool computes each connection’s expiration timestamp.

The pool should compute an expiration time as:
- If `ConnMaxLifetime <= 0`, connections should not expire by lifetime (i.e., behave as “no expiration”).
- If `ConnMaxLifetime > 0` and `ConnMaxLifetimeJitter == 0`, the expiration should be exactly `now + ConnMaxLifetime`.
- If `ConnMaxLifetime > 0` and `ConnMaxLifetimeJitter > 0`, apply a random jitter in the range `[-jitter, +jitter]` to the lifetime before computing expiration. That is, for a connection created at time `t0`, the effective lifetime should be `ConnMaxLifetime + delta` where `delta` is uniformly random and `-jitter <= delta <= +jitter`, and the expiration should be `t0 + effectiveLifetime`.

`ConnMaxLifetimeJitter` must be capped so it never exceeds `ConnMaxLifetime` (e.g., if `ConnMaxLifetime=30m` and jitter is configured as `1h`, the effective jitter must be treated as `30m`).

URL parsing must also support configuring the jitter. When calling `ParseURL` with query parameters:
- `conn_max_lifetime` should continue to set `ConnMaxLifetime`.
- A new parameter `conn_max_lifetime_jitter` should parse as a duration and set `ConnMaxLifetimeJitter`.
- The same capping rule applies when parsing from URL (jitter larger than lifetime must be reduced to the lifetime value).

After these changes, creating clients with either programmatic options or `ParseURL` should correctly populate `ConnMaxLifetimeJitter`, and pooled connections should no longer all expire at the same instant when jitter is configured.
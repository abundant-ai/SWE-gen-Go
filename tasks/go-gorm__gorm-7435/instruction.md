When using GORM in PrepareStmt mode, prepared statements are cached in an unbounded default map, which can grow without limit and effectively behave like a memory leak in long-running processes with many distinct SQL strings. GORM should support an LRU+TTL-backed cache for prepared statements that can evict old entries.

Add support for configuring prepared statement caching with a maximum size and an expiry time. A new constructor for the prepared statement manager should accept LRU configuration and choose the appropriate backing store.

Required behavior:
- GORM configuration must expose prepared statement cache settings:
  - `PrepareStmtMaxSize` (int): maximum number of cached prepared statements. A value of 0 must mean “unlimited size / no eviction by size”.
  - `PrepareStmtTTL` (time.Duration): how long an entry may live before it expires.
- When `PrepareStmt` is enabled and LRU settings are provided, the prepared statement manager must store statements in an LRU cache rather than a plain `map`.
- The prepared statement manager must use a statement-store abstraction (e.g., `StmtStore`) so that both the default map-backed store and the LRU-backed store can be used interchangeably. The store must support these operations:
  ```go
  type StmtStore interface {
      Get(key string) (*Stmt, bool)
      Set(key string, value *Stmt)
      Delete(key string)
      AllMap() map[string]*Stmt
  }
  ```
  `AllMap()` is used for introspection/debugging and should reflect only currently-live entries (expired entries must not remain visible).
- Expiration must actually remove entries: after waiting longer than the configured TTL, previously created prepared statements must no longer be present in the store.
  For example, if a DB connection is opened with `PrepareStmt: true`, `PrepareStmtMaxSize: 10`, and `PrepareStmtTTL: 20*time.Second`, and statements are created via a transaction, then after sleeping long enough (e.g., ~40 seconds), `len(conn.Stmts.AllMap())` should be `0`.
- Defaults must be safe and not surprising:
  - If LRU is not enabled/configured, behavior should match the existing default map caching.
  - TTL must have a sensible default when LRU is enabled but TTL is not set. If a “no eviction” mode is needed, it should use a very large TTL constant (e.g., years) rather than leaving entries stuck forever unintentionally.

The end result should prevent unbounded growth of the prepared statement cache when LRU is enabled, and should ensure statements are evicted/expired according to the configured TTL and/or size while keeping existing PrepareStmt behavior intact when the feature is not enabled.
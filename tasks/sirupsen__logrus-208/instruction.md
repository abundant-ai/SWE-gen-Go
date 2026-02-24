There is a bug in how log level filtering is applied for contextual loggers created from a base Logger. When creating an Entry (for example via NewEntry(logger) or logger.WithField(...)), changing the Entry’s Level does not correctly affect which log calls are emitted. As a result, it’s not possible to have different log levels for different context loggers/entries.

For example:

```go
log := New()
log.Level = InfoLevel

contextLogger := log.WithField("foo", "bar")
contextLogger.Level = ErrorLevel
contextLogger.Info("Hey, I won't be displayed!")
```

Expected behavior: because the contextual Entry has Level set to ErrorLevel, calling Info(...) on that Entry should not write anything.

Actual behavior: the message may still be emitted because level checks are not respecting the Entry’s own Level.

The logging methods on Entry should honor Entry.Level when deciding whether to output a message. Concretely:
- A newly created Entry should default its Level to the parent Logger’s Level.
- If Entry.Level is later changed (e.g., to WarnLevel), then lower-severity calls like entry.Info(...) must not be written.
- Calls at or above the Entry’s level (e.g., entry.Warn(...) when Entry.Level is WarnLevel) must be written.

This should apply consistently across Entry logging methods (e.g., Info, Warn, etc.) so that per-entry/per-context log levels work independently of the base Logger’s Level after the Entry is created.
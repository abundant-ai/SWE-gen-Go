There is currently no built-in way to reliably capture and inspect log messages emitted via logrus during tests. Implement a testing hook that can be attached to either a specific logger instance or the global logger, and that records emitted log entries for later assertions.

Add a `test.Hook` type that implements the logrus hook interface (`Fire(*logrus.Entry) error` and `Levels() []logrus.Level`). The hook must store all received entries in an `Entries []*logrus.Entry` slice in the order they are fired.

Provide the following functions and methods:

- `NewGlobal() *Hook`: installs the hook on the global logger (so that calls like `logrus.Error("...")` are captured) and returns the hook.
- `NewLocal(logger *logrus.Logger) *Hook`: installs the hook on the provided `*logrus.Logger` and returns the hook.
- `NewNullLogger() (*logrus.Logger, *Hook)`: creates a new logger that discards output (so tests don’t print to stdout/stderr), installs a local test hook on it, and returns both the logger and the hook.
- `(*Hook) LastEntry() *logrus.Entry`: returns the most recent logged entry, or `nil` if no entries have been recorded.
- `(*Hook) Reset()`: clears all recorded entries so that `len(hook.Entries)` becomes 0 and `LastEntry()` returns `nil`.

Expected behavior examples:

- After `logger, hook := NewNullLogger()`, `hook.LastEntry()` should be `nil` and `len(hook.Entries)` should be `0`.
- After `logger.Error("Hello error")`, `hook.LastEntry().Level` should be `logrus.ErrorLevel`, `hook.LastEntry().Message` should be `"Hello error"`, and `len(hook.Entries)` should be `1`.
- After additionally calling `logger.Warn("Hello warning")`, the last entry should have level `logrus.WarnLevel` and message `"Hello warning"`, and the total number of entries should be `2`.
- After `hook.Reset()`, `hook.LastEntry()` should again be `nil` and `len(hook.Entries)` should be `0`.
- After `hook := NewGlobal()` and then calling `logrus.Error("Hello error")`, the hook should capture that global log entry with the correct level/message, and `len(hook.Entries)` should be `1`.
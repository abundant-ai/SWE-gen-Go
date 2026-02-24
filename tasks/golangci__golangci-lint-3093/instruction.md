golangci-lint should support a new linter named "logrlint" for projects using github.com/go-logr/logr. The linter must detect incorrect key/value argument lists passed to logr logging calls and report a diagnostic when the number of arguments intended as key-value pairs is odd.

When a user enables the linter (e.g., via CLI enable flag for "logrlint"), golangci-lint should analyze calls made on a logr.Logger such as WithValues(...), Info(msg, keysAndValues...), and Error(err, msg, keysAndValues...). For these methods, any trailing arguments representing key/value pairs must come in an even count. If an odd number is provided, golangci-lint should emit an issue with the exact message:

"odd number of arguments passed as key-value pairs for logging"

Examples that must be reported:

- log := logr.Discard(); log.WithValues("key")
- log.Info("message", "key1", "value1", "key2", "value2", "key3")
- log.Error(err, "message", "key1", "value1", "key2")

Examples that must not be reported:

- log.Error(err, "message", "key1", "value1", "key2", "value2")

The new linter must be correctly registered and runnable under golangci-lint so that enabling it produces the above diagnostics and exit codes consistent with other linters (non-zero exit code when issues are found, zero when none are found).
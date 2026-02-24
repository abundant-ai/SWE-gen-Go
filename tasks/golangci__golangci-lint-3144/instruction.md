`golangci-lint` currently provides a linter named `logrlint` that validates structured logging calls for correct key/value usage. The upstream linter has been renamed and expanded, and `golangci-lint` needs to migrate to the new linter name `loggercheck` while keeping `logrlint` as a deprecated alias for backwards compatibility.

When users enable `loggercheck`, it should report an issue when a supported logging call is provided an odd number of key/value arguments. For example, calls like these must be diagnosed with the message:

`odd number of arguments passed as key-value pairs for logging`

This should apply to the supported logger APIs, including:
- `logr` style calls such as `log.Info(msg, keyvals...)`, `log.Error(err, msg, keyvals...)`, and `log.WithValues(keyvals...)`
- `klog` structured calls such as `klog.InfoS(msg, keyvals...)`
- `zap` sugared logger calls such as `sugar.Infow(msg, keyvals...)` and `sugar.Errorw(msg, keyvals...)`
- go-kit log calls such as `logger.Log(keyvals...)` and `kitlog.With(logger, keyvals...).Log(keyvals...)`

`loggercheck` must also support configuration that enables/disables checking per logger implementation. For example, when configured with only `zap: true` and `logr: false`, `klog: false`, only zap sugared calls should be checked and other logger calls should not produce findings; similarly for configurations that enable only `logr` or only `kitlog`.

In addition, `loggercheck` needs to support these optional behaviors via configuration:

1) Disallow printf-like format specifiers in the logging message and values when `no-printf-like: true` is set. If a string contains printf-like specifiers (e.g. `%s`, `%d`, `%w`, `%.2f`), `loggercheck` should emit:

`logging message should not use format specifier "%s"`

(or the matching specifier, e.g. `"%\.2f"` for `%.2f`). This should apply both to the main log message and to string values passed in key/value pairs.

2) Require logging keys to be inlined constant strings when `require-string-key: true` is set. If a key is not an inlined string literal or constant string, it should emit:

`logging keys are expected to be inlined constant strings, please replace "<key>" provided with string`

Also, keys must be ASCII/alphanumeric-only under this mode; if a key contains non-latin characters, it should emit:

`logging keys are expected to be alphanumeric strings, please remove any non-latin characters from "<key>"`

3) Allow custom rule definitions for additional logging methods/functions via configuration (a list of fully-qualified call patterns). Calls matching these configured rules should be validated for odd key/value argument counts the same way as the built-in supported loggers.

Finally, enabling `-Elogrlint` must continue to work as before (deprecated alias): it should run the same checks as `loggercheck` with default behavior and produce the same diagnostics for the same code patterns (including `logr`, `klog`, and zap sugared usage).
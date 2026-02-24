The logging package should support a function-based logging API that defers building log arguments until it’s known the message will actually be logged for the current level.

Currently, callers must eagerly construct the arguments passed to logging methods, which can be wasteful when the logger’s level filters the entry out. Introduce new methods that accept a callback returning the log arguments, and ensure the callback is only executed when the log level is enabled.

Implement function-based variants for the standard level methods on the exported logger API:

- InfoFn(func() []interface{})
- ErrorFn(func() []interface{})

Behavior requirements:

- When the logger is configured with a formatter (e.g., JSON) and the global log level is set to WarnLevel, calling InfoFn with a callback must NOT invoke the callback at all (because Info is below Warn).
- When the log level is WarnLevel, calling ErrorFn with a callback MUST invoke the callback exactly once (because Error is at or above Warn).
- The callback returns the same style of arguments as the existing logging methods (a slice of interface{}), and those returned arguments should be logged as if they had been passed directly to the corresponding non-Fn method.

Example scenario:

- Set global level to Warn.
- Call InfoFn(func() []interface{} { /* increments counter */ return []interface{}{ "Hello" } }) and verify the counter remains unchanged.
- Call ErrorFn(func() []interface{} { /* increments counter */ return []interface{}{ "Oopsi" } }) and verify the counter increments once.

The new API should behave consistently with the existing level filtering and formatting behavior, with the key difference being deferred evaluation of log arguments.
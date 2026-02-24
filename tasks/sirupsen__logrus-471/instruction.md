The current implementation of terminal detection in the text formatter hardcodes the file descriptor to check (always checks stderr), making it impossible to properly detect whether output is going to a terminal when logging to stdout or a custom file.

The `IsTerminal()` function currently has no parameters and always checks stderr's file descriptor. This causes issues when users want to log to stdout or a file - the formatter can't detect the actual output destination's terminal status.

Update the terminal detection to accept the actual output writer as a parameter. Specifically:

- Modify `IsTerminal()` to take an `io.Writer` parameter representing the actual output destination
- Detect whether the provided writer is a terminal by checking if it's an `*os.File` and using its file descriptor
- Update all platform-specific implementations (`terminal_notwindows.go`, `terminal_windows.go`, `terminal_solaris.go`, `terminal_appengine.go`)
- Pass the logger's output writer to `IsTerminal()` in the text formatter
- Fix the benchmark test `doBenchmark()` in `formatter_bench_test.go` to create a proper Entry with a Logger instance so it doesn't panic when the formatter tries to access the output writer

The goal is to enable proper terminal detection based on the actual output destination rather than always checking stderr, allowing color formatting to work correctly when logging to stdout or custom files.

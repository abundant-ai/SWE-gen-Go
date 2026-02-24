When a cobra.Command is executed without explicitly setting its argument list (e.g., the caller never calls Command.SetArgs), Cobra may fall back to using os.Args. This causes incorrect behavior when code is executed under `go test`, because os.Args contains `go test` flags such as `-v`, `-run`, `-count`, etc. As a result, commands that validate arguments (for example using Args validators like ExactArgs/NoArgs) can fail during test runs unless every test manually sets an empty args slice.

Cobra already contains a workaround intended to avoid picking up `go test` flags when running its own unit tests, but the existing detection is too specific (it assumes the test binary name matches a particular pattern like `cobra.test`) and it does not work reliably on Windows where the test binary name typically has a `.exe` suffix. The detection also should apply to downstream projects using Cobra as a module, not only to Cobra’s own repository.

Update Cobra’s argument initialization logic so that, when a Command is executed without user-provided args, it does not accidentally consume `go test` runner flags. In other words, if the current process is a Go test binary, Cobra should treat the default args as empty (or otherwise ignore the `go test` harness flags) unless the caller explicitly set args via Command.SetArgs.

This must work cross-platform (including Windows), and it must not rely on the test binary being named after the Cobra module. It should correctly detect typical `go test` binaries (including ones with platform-specific executable suffixes) so that running `go test -v` does not cause Cobra commands to see `-v` as a command argument.

Expected behavior example:

- Given `cmd := &cobra.Command{Use: "root", Args: cobra.NoArgs, Run: ...}`
- If the caller does not call `cmd.SetArgs(...)` and the code is running under `go test -v`, executing the command should not fail due to `-v` being interpreted as an argument.
- Commands that require specific positional arguments should only consider arguments provided by the caller (via SetArgs / Execute* wrappers that set args), not the `go test` flags.

Actual behavior to fix:

- Under `go test` (especially with `-v` or similar flags), commands executed without SetArgs may fail argument validation with errors consistent with “unknown flag: -v” or incorrect arg counts (depending on the command’s Args validator), because Cobra uses os.Args by default.

The fix should preserve normal non-test execution behavior (i.e., outside of `go test`, a command executed without SetArgs should continue to use os.Args as before).
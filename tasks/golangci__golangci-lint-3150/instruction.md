Running golangci-lint with the gocritic linter enabled can crash with a panic originating from go-critic/ruleguard, showing messages like:

`ERRO [runner] Panic: gocritic: package "model" (isInitialPkg: true, needAnalyzeSource: true): unreachable`

In other cases (notably when analyzing code that uses generics), the panic message is simply `unreachable`.

The expected behavior is that golangci-lint should not crash when gocritic/ruleguard encounters an internal rule initialization problem. Instead, golangci-lint should handle this situation gracefully: the gocritic linter should return an ordinary error (or otherwise report a non-panicking failure) so the overall run completes without a process panic.

Update the gocritic integration so that when embedded rule initialization fails (the underlying go-critic change is to return an error instead of panicking during embedded rule initialization), golangci-lint properly propagates that error and does not convert it into a panic. Ensure that configuration behavior related to gocritic check selection remains correct, including tag-based filtering through `newGoCriticSettingsWrapper(...)` and `filterByDisableTags(...)`, and that helper behavior like `intersectStringSlice(...)` continues to work as expected.

After the fix, running golangci-lint with `gocritic` enabled on projects that previously triggered the `unreachable` panic (including projects containing generic code) should no longer crash; it should either lint successfully or fail with a normal, user-readable error message rather than a panic.
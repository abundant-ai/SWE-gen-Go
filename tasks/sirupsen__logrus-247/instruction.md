A previous change accidentally broke Logrus’s public API around attaching errors to log entries. The API should support adding an error to an entry via the `WithError(err error)` method, and the error must be stored in the entry’s structured fields under the key defined by the global `ErrorKey` variable.

Currently, calling `WithError(err)` (both as a package-level helper and as an `*Entry` method) does not reliably store the passed error in `Entry.Data[ErrorKey]`, which is a breaking change for users that rely on structured error fields.

Fix the API so that:

- Calling `WithError(err)` returns an entry whose `Data` contains the exact `err` value under the key `"error"` when `ErrorKey` has its default value.

  Example behavior:
  ```go
  err := fmt.Errorf("kaboom")
  e := WithError(err)
  // expected:
  e.Data["error"] == err
  ```

- Calling `entry.WithError(err)` behaves the same way for an explicitly created `*Entry` (e.g., from `NewEntry(New())`), storing the error under the current `ErrorKey`.

- If `ErrorKey` is changed at runtime (e.g., `ErrorKey = "err"`), subsequent calls to `WithError` / `entry.WithError` must store the error under the new key:
  ```go
  ErrorKey = "err"
  e := entry.WithError(err)
  // expected:
  e.Data["err"] == err
  ```

Additionally, panicking entry methods must preserve structured fields in the panic value:

- When calling `entry.WithField("err", someErr).Panicln("kaboom")`, the function must panic with a value of type `*Entry`. The recovered `*Entry` must have `Message == "kaboom"` and must include `Data["err"] == someErr`.

- When calling `entry.WithField("err", someErr).Panicf("kaboom %v", true)`, it must panic with a `*Entry` whose `Message == "kaboom true"` and whose `Data["err"] == someErr`.

The goal is to restore the previously supported public API behavior (before the breaking change) and ensure it remains compatible for downstream users expecting `WithError` and the panic methods to behave as described.
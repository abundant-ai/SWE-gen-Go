logrus is missing a convenient way to attach an error value into a log entry’s structured context. Users frequently want to do this in a consistent way so that downstream tooling can reliably find the error under the configured error key.

Implement a new helper function `WithError(err error) *Entry` that returns an entry with the error stored in the entry context under `ErrorKey` (by default this key is the string "error"). This should behave like `WithField(ErrorKey, err)` on the standard/global logger.

Also implement an `(*Entry).WithError(err error) *Entry` method that returns a copy of the entry with the same behavior: the provided `err` must be stored in `Data[ErrorKey]`. This must respect runtime changes to the global `ErrorKey` (e.g., if `ErrorKey` is changed to "err", calling `entry.WithError(err)` must store the error under "err").

Integrate this with existing error extraction behavior via `(*Entry).ToError()`: when the entry’s data contains an `error` value stored under `ErrorKey`, calling `.ToError()` on an emitted entry should return that same error value. If there is no error in the data, or if the value under `ErrorKey` is not an `error` type (e.g., a string), `ToError()` should return `nil`.

Expected behaviors:
- `WithError(err).Data["error"]` is `err` when `ErrorKey` is left at its default.
- `entry.WithError(err).Data[ErrorKey]` is `err` for any current value of `ErrorKey`.
- If an entry contains `Data[ErrorKey] = err`, then `entry.Debug("Hello").ToError()` returns `err`.
- If `Data[ErrorKey]` is missing or is not an `error`, then `ToError()` returns `nil`.
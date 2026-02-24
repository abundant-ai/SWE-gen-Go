golangci-lint is missing support for the `zerologlint` analyzer (https://github.com/ykadowak/zerologlint). Users should be able to enable it via `-Ezerologlint`, and when enabled it must report issues for incorrect `zerolog` usage where an event is created but never dispatched.

When code calls `github.com/rs/zerolog/log` event builders like `log.Error()`, `log.Info()`, `log.Fatal()`, `log.Debug()`, or `log.Warn()` and the resulting event is not eventually dispatched via `.Msg(...)` or `.Send()`, golangci-lint should emit an issue with the message:

`must be dispatched by Msg or Send method`

This should be reported both for direct standalone calls and for chained calls that build up fields but never dispatch, for example:

- `log.Error()`
- `log.Error().Err(err)`
- `log.Error().Err(err).Str("foo", "bar").Int("foo", 1)`
- assignments like `logger := log.Error()` where the assigned value is not later dispatched
- conditional reassignment cases like:
  - `logger2 := log.Info()`
  - `if err != nil { logger2 = log.Error() }`
  - followed by field-building without a final `.Msg(...)`/`.Send()`

At the same time, no issues should be reported for properly dispatched events, including but not limited to:

- `log.Fatal().Send()`
- `log.Panic().Msg("")`
- `log.Error().Msg("...")`
- `log.Error().Str("foo","bar").Send()`
- `logger := log.Error(); logger.Send()`
- chained use that includes `zerolog.Dict()` and then ends in `.Send()` or `.Msg(...)`

After implementing the integration, running golangci-lint with `--disable-all -Ezerologlint` on code containing the incorrect patterns above should exit non-zero and produce the expected diagnostics, while code containing only the correct dispatched patterns should exit successfully with no `zerologlint` findings.
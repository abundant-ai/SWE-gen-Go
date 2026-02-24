Cobra’s “unknown command” handling should provide better suggestions when a user mistypes a command.

Currently, when executing a command with an invalid subcommand (e.g., running `app commt` when the valid subcommand is `commit`), Cobra reports an unknown command error but does not reliably suggest intended commands in several common cases.

Implement improved suggestion behavior with these requirements:

When a user enters an unknown command name, Cobra should compute a list of suggested valid commands and include them in the error output in a “Did you mean this?” style message.

Suggestion matching must include:

1) Prefix matches: if the unknown token is a prefix of an existing command name, that command should be suggested. For example, if a valid command is `times` and the user types `ti`, `times` should appear as a suggestion.

2) Explicit suggestions via a new `SuggestFor` field on `Command`: a command may declare additional strings that should map to it for suggestion purposes (without making them actual aliases). For example, if a command has `Use: "times"` and `SuggestFor: []string{"counts"}`, then when the user types `counts` Cobra should suggest `times`.

The `SuggestFor` mechanism must not change command execution or parsing semantics: these strings are only for suggestions shown on unknown-command errors, not for actual command invocation.

Also ensure that suggested commands respect normal visibility rules: commands marked as hidden should not be suggested.

The new behavior should integrate with the existing command execution flow so that suggestions appear when `Execute()` fails due to an unknown command, and the suggestion list should include both prefix-based matches and `SuggestFor`-based matches when applicable.
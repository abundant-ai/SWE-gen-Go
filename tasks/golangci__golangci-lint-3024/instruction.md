golangci-lint is missing support for the `interfacebloat` linter (https://github.com/sashamelentyev/interfacebloat), which reports interfaces that have too many methods.

Add a new linter named `interfacebloat` that can be enabled via `-Einterfacebloat` and behaves consistently with other integrated linters. When enabled, it must report a diagnostic for any interface type (including anonymous interfaces) that declares more than 10 methods, using the message format:

"the interface has more than 10 methods: 11"

The method count must include methods brought in via embedded interfaces. For example, if an interface embeds two other interfaces with 5 and 6 methods respectively, the combined interface must be flagged as having 11 methods.

The linter must also analyze interfaces in these contexts:
- named interface types
- anonymous interface literals used in variable declarations
- anonymous interface return types of functions
- interface-typed fields inside structs
- nested/embedded anonymous interface blocks inside another interface

It must not report anything for interfaces with 10 methods or fewer.

The integration should work in a normal golangci-lint run: enabling `interfacebloat` should produce findings at the correct source locations for offending interfaces, and disabling it should produce no findings from this linter.
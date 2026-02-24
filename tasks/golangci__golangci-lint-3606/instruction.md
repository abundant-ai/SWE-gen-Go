golangci-lint needs a native output format that TeamCity can parse as inspections in its “test”/inspections UI. Currently there is no TeamCity printer, so users must post-process JSON output into TeamCity service messages. Add a new printer/output format that emits TeamCity service messages for each linter and issue.

Implement a printer constructor named NewTeamCity(writer) and a Print(ctx, issues) method that writes TeamCity “InspectionType” and “inspection” service messages.

Behavior requirements:

When Print is called with a list of issues, it must group issues by their linter name (Issue.FromLinter). For each distinct linter encountered, it must first emit exactly one line describing the inspection type:

##teamcity[InspectionType id='<linter>' name='<linter>' description='<linter>' category='Golangci-lint reports']

Then, for each issue (in the original order), emit one “inspection” line:

##teamcity[inspection typeId='<linter>' message='<issue text>' file='<filename>' line='<line>' SEVERITY='<severity>']

Field mapping rules:
- typeId is the linter name (Issue.FromLinter).
- message is Issue.Text.
- file is Issue.Pos.Filename.
- line is Issue.Pos.Line rendered as a base-10 integer.
- SEVERITY is empty for non-error severities (including missing severity), and must be 'ERROR' when Issue.Severity is 'error' (case-insensitive match acceptable, but output must be exactly 'ERROR' in that case).

Ordering rules:
- The output must be deterministic.
- The “InspectionType” declaration for a linter must appear before the first issue line for that linter.
- Issue lines must follow the order of the provided issues slice.

The printer must end each emitted TeamCity service message with a newline.

Also implement a helper function limit(s string, max int) string used to truncate strings by Unicode code points (runes), not bytes:
- If max <= 0, return an empty string.
- If s is longer than max runes, return the first max runes.
- If s is max runes or shorter, return s unchanged.

The TeamCity output format should be selectable like other golangci-lint output formats, so that running golangci-lint with the TeamCity format produces exactly the service-message lines described above.
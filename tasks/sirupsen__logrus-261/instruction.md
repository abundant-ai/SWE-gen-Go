The built-in Airbrake hook in Logrus currently uses an outdated Airbrake v2 API client implementation. This causes integration problems for users: the “official” Airbrake hook does not match the current Airbrake client expectations, and at the same time some users rely on the older v2-style behavior for Errbit/in-house Airbrake-compatible endpoints.

Update the Airbrake integration so that:

1) The official Logrus Airbrake hook uses the official Airbrake Go client (gobrake) and is compatible with modern Airbrake usage. Creating and using the Airbrake hook should work with the gobrake notifier and should send notices without requiring the legacy v2 API behavior.

2) The previous Logrus-provided Airbrake hook implementation is not removed, but it must be preserved under a new “legacy” hook name. Users who depended on the older behavior (e.g., Errbit) should be able to instantiate and use the legacy hook explicitly, without breaking existing runtime expectations of that older API.

3) The public API should clearly distinguish the two hooks by name: the default/official “Airbrake” hook should correspond to the gobrake-backed implementation, and the old implementation should be accessible via a legacy-named constructor/type (e.g., legacy Airbrake hook).

Fix any breakages in hook behavior so that logging through Logrus triggers the appropriate Airbrake notice delivery for each hook type. In particular, ensure that constructing the hook with typical configuration (project/key/env or equivalent notifier configuration) results in notices being created and sent, and that the legacy hook continues to behave as it did previously when used explicitly.

If a user upgrades and continues to use the Airbrake hook as documented, it should use gobrake. If they need the old behavior for Airbrake-compatible endpoints, they should be able to switch to the legacy hook without errors and still have notices sent as before.
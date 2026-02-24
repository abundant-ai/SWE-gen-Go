Running the experimental implementation of `init` can incorrectly continue past configuration errors and attempt to initialize the state store/backend with insufficient configuration. This shows up in scenarios where the configuration contains errors that prevent the required provider for the state store (PSS) from being selected or downloaded (for example, errors in `required_providers` or other early configuration parsing issues). In these cases, `InitCommand.Run` should stop earlier and return the configuration diagnostics, rather than proceeding into backend/state-store initialization.

Currently, `InitCommand.Run` can reach the state store initialization step even when there are already error diagnostics from the “early configuration” phase. This leads to follow-on failures that are confusing/misleading (because the real problem is the earlier configuration error) and may involve attempts to initialize a state store with missing/unknown provider information.

Update `InitCommand.Run` so that diagnostics are acted on at the correct points in the init sequence:

- Terraform version compatibility must still be checked before surfacing configuration-related errors.
- After version compatibility is confirmed, if there are any early configuration diagnostics with errors (before module installation / full config load), `init` must return immediately with those diagnostics and must not attempt backend/state-store initialization.
- Backend/state-store initialization should only run when the configuration is sufficiently valid to determine and install any required providers for the state store.
- Errors from full configuration loading (including module installation) should not be reported before backend/state-store initialization errors, even if module installation occurs earlier internally; the user-visible diagnostic precedence should remain: version compatibility, then early config errors, then backend/state-store init errors, then full-config/module errors.

Reproduction sketch:

1) Create a configuration that enables the experimental state store/provider selection feature, but includes a configuration error that prevents resolving/downloading the provider needed for the state store (for example, an invalid `required_providers` entry or other parse/validation error that blocks provider discovery).
2) Run `terraform init`.

Expected behavior: `terraform init` exits non-zero and reports the original configuration error diagnostics, and it does not attempt to initialize the backend/state store.

Actual behavior: `terraform init` continues into backend/state-store initialization despite existing configuration error diagnostics, causing additional failures that obscure the real configuration error and/or reflect missing state-store provider configuration.
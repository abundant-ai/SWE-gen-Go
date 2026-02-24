The UI codebase uses direct route/controller transition methods (e.g., calling `this.transitionTo(...)`) in places that should instead use the injected router service’s `transitionTo` method (`this.router.transitionTo(...)`). Newer Ember versions deprecate the direct routing transition methods, so the current implementation emits deprecation warnings and can break as Ember removes those APIs.

Update the routing/transition logic so that any mixins/components/routes that perform navigations do so via the router service. In particular, the `with-blocking-actions` mixin must navigate by calling `router.transitionTo` when performing its post-action hooks.

The following behaviors must hold:

- `afterCreate(value)` must delegate to `afterUpdate(value)` and return the same value `afterUpdate` returns.
- `afterUpdate()` must compute a target route name by removing the last segment of the current `routeName` (e.g., if `routeName` is `dc.kv.edit`, the target is `dc.kv`), then call `this.router.transitionTo(targetRouteName)` and return the computed target route name.
- `afterDelete()` must behave similarly, except when the last segment of the current `routeName` is exactly `index`:
  - If `routeName` ends with `.index` (e.g., `dc.kv.index`), it must call `this.refresh()` and return whatever `refresh()` returns.
  - Otherwise (e.g., `dc.kv.edit`), it must transition using `this.router.transitionTo(targetRouteName)` where `targetRouteName` is the current `routeName` without its last segment, and return that target route name.
- The error hooks `errorCreate`, `errorUpdate`, and `errorDelete` must continue to return the first argument they are given (i.e., they should be pass-through and not change return types).

After these changes, there should be no remaining direct uses of deprecated transition APIs in the updated areas, and navigation should consistently go through the router service.
A race in `balancergroup` shutdown can leak child balancers (and their goroutines) when `Close()` runs concurrently with operations like `Remove()` (and other methods that may add entries to an internal deletion/idle cache). This shows up as goroutine leaks in higher-level scenarios (e.g., priority switching where a lower-priority child is moved to an idle/deletion cache and then the group is shut down soon after). In the failure mode, a child balancer is not closed, and transitive children remain running (example symptoms include leaked goroutines from long-running balancer loops such as an outlier-detection balancer and its child balancer).

The `balancergroup` must become “terminal” after `Close()` is called: once `Close()` begins, the group should be marked closed in a way that prevents any subsequent method calls from creating/starting new children, updating children, or adding anything back into internal caches. `Close()` must be safe against concurrent calls from other goroutines and must ensure all existing children are properly closed exactly once, with no possibility of a child being skipped due to concurrent cache manipulation.

After `Close()` has been called, the following methods must be guarded so they do not resurrect state, start work, or mutate internal caches: `ExitIdle()`, `ExitIdleOne(id)`, `UpdateClientConnState(id, state)`, and `ResolverError(id, err)`. These calls should become no-ops (or otherwise behave safely) when the group is closed.

Expected behavior:
- Running scenarios that rapidly switch between child balancers and then shut down the group should not leak goroutines or leave any child balancer running.
- Concurrent `Close()` with `Remove()` (and other operations that may manage the idle/deletion cache) must not result in a child balancer being left unclosed.
- Once `Close()` is invoked, `balancergroup` must not be restartable: no later call to `Add`, `UpdateClientConnState`, `ExitIdle*`, or `ResolverError` should cause any child balancer to be created, reactivated from an idle cache, or have work scheduled.

Actual behavior (current bug):
- Under certain timing, a child balancer can be moved into an idle/deletion cache and then missed during shutdown because `Close()` and `Remove()` overlap; this leaves the child (and its descendants) running and causes leaked goroutines detected at the end of the run.
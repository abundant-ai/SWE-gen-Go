The xDS dependency manager currently does not watch cluster-related resources (CDS and cluster endpoints such as EDS/DNS) as part of building and maintaining the transitive xDS configuration dependencies. As a result, when a Listener/Route configuration ultimately references a Cluster, the dependency manager can emit an incomplete configuration update: it may contain Listener/Route information but not the resolved Cluster and endpoint information needed to represent the full dependency graph.

Add support for watching cluster resources and their endpoints in the dependency manager, and gate the behavior behind a temporary boolean flag named `xdsdepmgr.EnableClusterAndEndpointsWatch` which is disabled by default. When the flag is enabled, the dependency manager must:

- Start and maintain CDS watches for cluster names discovered through route configuration / cluster specifiers.
- For each resolved Cluster, start and maintain the appropriate endpoint watches based on the cluster type:
  - If the cluster uses EDS, start an EDS watch for the EDS service name (or the cluster name when no explicit EDS service name is configured).
  - If the cluster uses DNS/logical DNS, start the appropriate DNS-related watch so endpoint updates are reflected.
- Correctly stop/cancel obsolete watches when dependencies change (e.g., when Listener updates point to a new RouteConfiguration, when routes switch to different clusters, or when a cluster changes its endpoint configuration).

The dependency manager must deliver updates via its watcher interface (e.g., a `ConfigWatcher` receiving `Update(*xdsresource.XDSConfig)` and `Error(error)` callbacks) such that an update represents a consistent snapshot: once the Listener/Route references a cluster, the emitted `xdsresource.XDSConfig` should include the corresponding Cluster and endpoint resources after they are resolved, and subsequent changes to clusters/endpoints should trigger new updates.

When the flag is disabled (the default), existing behavior must remain unchanged and the new cluster/endpoint watches must not be used in the normal RPC/resolver paths.

Also ensure the existing xDS resolver behavior continues to correctly react to dependency changes (e.g., when a Listener switches to a new RouteConfiguration name, the old RouteConfiguration watch should be canceled and the new one started; similarly, cluster/endpoint watches must follow the currently active configuration when enabled via the flag).
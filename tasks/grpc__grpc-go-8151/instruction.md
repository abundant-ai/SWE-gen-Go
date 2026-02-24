In gRPC-Go v1.71.0, some clients that use client-side load balancing (e.g., round_robin via service config) can start failing RPCs with:

rpc error: code = Unavailable desc = no children to pick from

This regression occurs when a custom name resolver updates addresses using the deprecated resolver.ClientConn NewAddress API. After updating from v1.70.0 to v1.71.0, calls that previously worked can intermittently or consistently fail with the error above, even though the resolver is providing usable addresses.

The resolver update flow must correctly propagate address updates from custom resolvers that call NewAddress so that the balancer has ready subchannels (“children”) to pick from. When a resolver provides addresses through NewAddress, the client connection and load balancer should behave equivalently to when the resolver provides addresses through the newer state update APIs: endpoints should be created/updated, pickers should not get stuck in a state with zero children, and RPCs should not fail with Unavailable solely because the resolver used NewAddress.

Reproduction scenario:
- Dial a target using a service config that enables round_robin (e.g. {"loadBalancingPolicy":"round_robin"}).
- Use a custom resolver that reports backend addresses by calling resolver.ClientConn.NewAddress.
- Attempt RPCs after the resolver provides at least one valid address.

Expected behavior:
- RPCs should proceed normally once at least one address is reported; no spurious "no children to pick from" errors should occur.

Actual behavior:
- RPCs can fail with Unavailable and the message "no children to pick from" despite the resolver providing addresses via NewAddress.

Fix the regression so that custom resolvers using the deprecated NewAddress API do not break client-side load balancing and do not cause pickers to see an empty child set when addresses are available.
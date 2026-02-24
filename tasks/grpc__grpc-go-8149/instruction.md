When using client-side load balancing (e.g., the "round_robin" policy via service config) with a custom name resolver, RPCs can fail after upgrading to gRPC-Go v1.71.0 with:

rpc error: code = Unavailable desc = no children to pick from

This happens when the custom resolver uses the deprecated resolver.ClientConn method NewAddress (or NewAddresses) to provide backend addresses. In v1.71.0, the resolver wrapper correctly converts resolver.State.Addresses into resolver.State.Endpoints when UpdateState is used, but the equivalent conversion is missing when the resolver reports addresses via the NewAddress/NewAddresses API. As a result, the balancer can receive a state with no usable endpoints/children, leading to "no children to pick from".

Fix the resolver wrapper so that when a resolver calls NewAddress/NewAddresses, the provided resolver.Address entries are translated into endpoints in the same way as they are for UpdateState. After this change, a client using round_robin with a resolver that only calls NewAddress/NewAddresses should successfully create picker children and not fail RPCs with "no children to pick from" solely due to using the deprecated address update API.
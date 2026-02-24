Introduce an experimental generic address map type `AddressMapV2[T]` to replace the existing non-generic `AddressMap`, and deprecate `AddressMap`.

The new API must provide a constructor `NewAddressMapV2[T]()` and support storing and retrieving values keyed by `resolver.Address`, where address equality follows the same semantics as the existing address map: addresses are considered the same if they match on `Addr`, `ServerName`, and `Attributes`, but differences in `BalancerAttributes` must be ignored (i.e., two addresses that differ only by `BalancerAttributes` must alias to the same key).

`AddressMapV2[T]` must support at least the following behaviors:

- `Len() int` returns the count of unique address keys currently stored. Repeatedly setting the same logical address key must not increase the length. Setting a key using an address that aliases an existing key (differs only by `BalancerAttributes`) must also not increase the length.

- `Set(addr Address, value T)` stores `value` for `addr`, overwriting any existing value for the same logical address key.

- `Get(addr Address) (T, bool)` returns the stored value and `true` when the logical address key exists, otherwise returns the zero value of `T` and `false`.

- `Delete(addr Address)` removes the entry for the logical address key if present. Deleting a non-existent key must be a no-op.

- `Keys() []Address` (or equivalent) must return the set of stored address keys with no duplicates according to the address equality semantics above.

Additionally, the implementation must correctly distinguish addresses which differ in any of the compared fields. For example, changing any of `Addr`, `ServerName`, or entries/types/values within `Attributes` must cause addresses to be treated as different keys.

`AddressMap` should be marked deprecated in a way consistent with Go deprecation conventions, but must remain functional for compatibility.
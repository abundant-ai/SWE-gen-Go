GORM’s single-record retrieval and scanning APIs fail when the destination is a nil pointer to a struct (or similar), even when the caller passes the address of that pointer (pointer-to-pointer). This prevents common repository patterns like returning `(*User, error)` where the method initializes the pointer via `First`/`Take`/`Last`.

Currently, code like this returns an error such as `invalid value` instead of allocating the destination and scanning into it:

```go
var user *User
err := db.Where("id = ?", 1).First(&user).Error
// expected: user is non-nil and populated when a row exists
// actual: error (e.g., "invalid value") and user remains nil
```

The same problem applies to `Take` and `Last` when the destination is a nil pointer and the caller passes `&dest`.

Expected behavior:
- `First(&dest)`, `Take(&dest)`, and `Last(&dest)` must support `dest` being a nil pointer to a struct (and more generally a pointer destination that needs initialization) when provided as a pointer-to-pointer. When a matching row exists, GORM should allocate the underlying value, populate it, and set `dest` to point to it.
- Scanning into a nil pointer destination via `Scan(&dest)` should also work in the same way: when `dest` is `*T` and is nil, `Scan(&dest)` should allocate a `T`, scan into it, and update `dest`.
- Existing behavior for non-nil struct pointers, struct values, maps, slices, and already-initialized pointers must remain unchanged.

Example scenarios that should work after the fix:

```go
// Single object retrieval into nil pointer
var user *User
if err := db.First(&user).Error; err != nil { /* handle */ }
if user == nil { /* should not happen when a row exists */ }

// Last should also initialize
var lastUser *User
_ = db.Last(&lastUser).Error

// Scan into nil pointer result type
type Result struct { ID uint; Name string; Age int }
var r *Result
_ = db.Table("users").Select("id, name, age").Where("id = ?", someID).Scan(&r).Error
// expected: r != nil and fields populated
```

When no rows are found, behavior should follow GORM’s existing conventions for `First`/`Last`/`Take` (e.g., returning the usual not-found error where applicable) without causing panics, and the destination pointer should not be erroneously initialized with garbage data.
GORM can infer the wrong relationship type (treating a struct field as has_one instead of belongs_to, or vice-versa) when the owner and related structs have identically named key fields and a custom `foreignKey`/`references` tag is used. This causes incorrect schema relationships, wrong foreign key placement during migrations, and incorrect preload/query behavior.

A common reproduction is:

```go
type User struct {
  ID     int
  Name   string
  UserID int // adding this field triggers the bug
}

type Profile struct {
  ID     int
  UserID int
  User   User `gorm:"foreignKey:UserID"`
}
```

When preloading `Profile.User`, GORM should treat `Profile.User` as a belongs-to relation using `Profile.UserID` as the foreign key that references `User.ID`. Expected behavior is that preloading issues a query equivalent to selecting users by `users.id IN (...)` (or `= 1` for a single row). Actual behavior is that GORM may instead generate SQL that filters on `users.user_id`, e.g.:

```sql
SELECT * FROM `users` WHERE `users`.`user_id` = 1
```

and may also end up loading unrelated rows (e.g. `SELECT * FROM profiles` without proper association filtering), resulting in missing/incorrect `Profile.User` data.

The same class of failure appears when both sides share a field name that matches the specified `ForeignKey`, e.g.:

```go
type Product struct {
  ProductID  string `gorm:"primaryKey"`
  MaterialID string
  SalesItem  SalesItem `gorm:"foreignKey:MaterialID"`
}

type SalesItem struct {
  MaterialID string `gorm:"primaryKey"`
}
```

In this case, GORM should infer that `Product` belongs to `SalesItem` (foreign key on `Product.MaterialID` referencing `SalesItem.MaterialID`). Instead, it may reverse the association and place the foreign key on the `SalesItem` side.

Fix relationship parsing/inference so that:

1) When a struct field is tagged with `ForeignKey:<field>` (and optionally `References:<field>`), GORM consistently infers the correct relation direction and builds `schema.Relationship` with the correct `Type` (`schema.BelongsTo` vs `schema.HasOne`) even if both structs contain a field with the same name as the foreign key.

2) The produced relationship `References` must map the referenced primary/target field on the related schema to the foreign key field on the owning schema correctly (e.g. `User.ID` <- `Profile.UserID` for the `Profile.User` case).

3) Preload and migration behavior should follow from the corrected relationship: preloading should join/filter using the correct referenced field (typically the related model primary key unless overridden by `References`), and foreign keys should be created on the correct table.

4) Existing explicit overrides must continue to work: `ForeignKey` alone, `ForeignKey` + `References`, and `References`-only patterns should still yield the expected belongs-to relationship when used on an owning struct field that points to another struct.

5) Avoid regressions where the relationship parser rejects valid configurations with an error like:

```
invalid field found for struct <...>'s field <...>: define a valid foreign key for relations or implement the Valuer/Scanner interface
```

This error should not occur for valid belongs-to/has-one mappings like the examples above, even when key field names overlap between the two structs.
///|
test "panic Attrs::set rejects direct cycles" {
  let attrs = empty_attrs()
  attrs.set("self", Val(attrs_value(attrs)))
}

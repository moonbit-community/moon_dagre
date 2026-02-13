///|
// Upstream: dagre-reference/test/unique-id-test.js
test "unique_id generates prefixed ids" {
  let id = unique_id("_root")
  assert_eq(id.contains("[object undefined]"), false)
  assert_eq(id.has_prefix("_root"), true)
}

///|
test "unique_id values are distinct" {
  let first = unique_id("name")
  let second = unique_id("name")
  let third = unique_id("name")
  assert_eq(first == second, false)
  assert_eq(second == third, false)
}

///|
test "unique_id with numeric prefix string" {
  let id = unique_id("99")
  assert_eq(id.has_prefix("99"), true)
}

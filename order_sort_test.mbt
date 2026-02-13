///|
// Upstream: dagre-reference/test/order/sort-test.js
test "order_sort sorts nodes by barycenter" {
  let input = [
    order_entry(["a"], 0, barycenter=Some(2.0), weight=Some(3.0)),
    order_entry(["b"], 1, barycenter=Some(1.0), weight=Some(2.0)),
  ]
  let out = order_sort(input)
  assert_eq(out.vs, ["b", "a"])
  order_sort_assert_opt_double(
    out.barycenter,
    Some((2.0 * 3.0 + 1.0 * 2.0) / 5.0),
  )
  order_sort_assert_opt_double(out.weight, Some(5.0))
}

///|
test "order_sort can sort super-nodes" {
  let input = [
    order_entry(["a", "c", "d"], 0, barycenter=Some(2.0), weight=Some(3.0)),
    order_entry(["b"], 1, barycenter=Some(1.0), weight=Some(2.0)),
  ]
  let out = order_sort(input)
  assert_eq(out.vs, ["b", "a", "c", "d"])
  order_sort_assert_opt_double(
    out.barycenter,
    Some((2.0 * 3.0 + 1.0 * 2.0) / 5.0),
  )
  order_sort_assert_opt_double(out.weight, Some(5.0))
}

///|
test "order_sort biases to left by default" {
  let input = [
    order_entry(["a"], 0, barycenter=Some(1.0), weight=Some(1.0)),
    order_entry(["b"], 1, barycenter=Some(1.0), weight=Some(1.0)),
  ]
  let out = order_sort(input)
  assert_eq(out.vs, ["a", "b"])
  order_sort_assert_opt_double(out.barycenter, Some(1.0))
  order_sort_assert_opt_double(out.weight, Some(2.0))
}

///|
test "order_sort biases to right with bias_right=true" {
  let input = [
    order_entry(["a"], 0, barycenter=Some(1.0), weight=Some(1.0)),
    order_entry(["b"], 1, barycenter=Some(1.0), weight=Some(1.0)),
  ]
  let out = order_sort(input, bias_right=true)
  assert_eq(out.vs, ["b", "a"])
  order_sort_assert_opt_double(out.barycenter, Some(1.0))
  order_sort_assert_opt_double(out.weight, Some(2.0))
}

///|
test "order_sort can sort nodes without barycenter" {
  let input = [
    order_entry(["a"], 0, barycenter=Some(2.0), weight=Some(1.0)),
    order_entry(["b"], 1, barycenter=Some(6.0), weight=Some(1.0)),
    order_entry(["c"], 2),
    order_entry(["d"], 3, barycenter=Some(3.0), weight=Some(1.0)),
  ]
  let out = order_sort(input)
  assert_eq(out.vs, ["a", "d", "c", "b"])
  order_sort_assert_opt_double(out.barycenter, Some((2.0 + 6.0 + 3.0) / 3.0))
  order_sort_assert_opt_double(out.weight, Some(3.0))
}

///|
test "order_sort handles no barycenters" {
  let input = [
    order_entry(["a"], 0),
    order_entry(["b"], 3),
    order_entry(["c"], 2),
    order_entry(["d"], 1),
  ]
  let out = order_sort(input)
  assert_eq(out.vs, ["a", "d", "c", "b"])
  assert_eq(out.barycenter, None)
  assert_eq(out.weight, None)
}

///|
test "order_sort handles barycenter 0" {
  let input = [
    order_entry(["a"], 0, barycenter=Some(0.0), weight=Some(1.0)),
    order_entry(["b"], 3),
    order_entry(["c"], 2),
    order_entry(["d"], 1),
  ]
  let out = order_sort(input)
  assert_eq(out.vs, ["a", "d", "c", "b"])
  order_sort_assert_opt_double(out.barycenter, Some(0.0))
  order_sort_assert_opt_double(out.weight, Some(1.0))
}

///|
fn order_sort_assert_opt_double(
  actual : Double?,
  expected : Double?,
) -> Unit raise {
  if actual is Some(actual) && expected is Some(expected) {
    let diff = if actual > expected {
      actual - expected
    } else {
      expected - actual
    }
    assert_eq(diff < 0.000000001, true)
  } else {
    assert_eq(actual, expected)
  }
}

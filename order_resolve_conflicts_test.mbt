///|
// Upstream: dagre-reference/test/order/resolve-conflicts-test.js
test "order_resolve_conflicts returns nodes unchanged without constraints" {
  let cg = Graph::new()
  let input = [
    order_bary_entry("a", barycenter=Some(2.0), weight=Some(3.0)),
    order_bary_entry("b", barycenter=Some(1.0), weight=Some(2.0)),
  ]
  let out = order_resolve_conflicts(input, cg)
  out.sort_by(order_resolve_conflicts_sort_by_first_vs)
  assert_eq(out.length(), 2)
  order_resolve_conflicts_assert_entry(out[0], ["a"], 0, Some(2.0), Some(3.0))
  order_resolve_conflicts_assert_entry(out[1], ["b"], 1, Some(1.0), Some(2.0))
}

///|
test "order_resolve_conflicts coalesces nodes on conflict" {
  let cg = Graph::new()
  let input = [
    order_bary_entry("a", barycenter=Some(2.0), weight=Some(3.0)),
    order_bary_entry("b", barycenter=Some(1.0), weight=Some(2.0)),
  ]
  cg.set_edge("a", "b")
  let out = order_resolve_conflicts(input, cg)
  assert_eq(out.length(), 1)
  order_resolve_conflicts_assert_entry(
    out[0],
    ["a", "b"],
    0,
    Some((3.0 * 2.0 + 2.0 * 1.0) / 5.0),
    Some(5.0),
  )
}

///|
test "order_resolve_conflicts coalesces chain conflicts" {
  let cg = Graph::new()
  let input = [
    order_bary_entry("a", barycenter=Some(4.0), weight=Some(1.0)),
    order_bary_entry("b", barycenter=Some(3.0), weight=Some(1.0)),
    order_bary_entry("c", barycenter=Some(2.0), weight=Some(1.0)),
    order_bary_entry("d", barycenter=Some(1.0), weight=Some(1.0)),
  ]
  cg.set_path(["a", "b", "c", "d"])
  let out = order_resolve_conflicts(input, cg)
  assert_eq(out.length(), 1)
  order_resolve_conflicts_assert_entry(
    out[0],
    ["a", "b", "c", "d"],
    0,
    Some(2.5),
    Some(4.0),
  )
}

///|
test "order_resolve_conflicts treats missing barycenter as violating constraints #1" {
  let cg = Graph::new()
  let input = [
    order_bary_entry("a"),
    order_bary_entry("b", barycenter=Some(1.0), weight=Some(2.0)),
  ]
  cg.set_edge("a", "b")
  let out = order_resolve_conflicts(input, cg)
  assert_eq(out.length(), 1)
  order_resolve_conflicts_assert_entry(
    out[0],
    ["a", "b"],
    0,
    Some(1.0),
    Some(2.0),
  )
}

///|
test "order_resolve_conflicts treats missing barycenter as violating constraints #2" {
  let cg = Graph::new()
  let input = [
    order_bary_entry("a"),
    order_bary_entry("b", barycenter=Some(1.0), weight=Some(2.0)),
  ]
  cg.set_edge("b", "a")
  let out = order_resolve_conflicts(input, cg)
  assert_eq(out.length(), 1)
  order_resolve_conflicts_assert_entry(
    out[0],
    ["b", "a"],
    0,
    Some(1.0),
    Some(2.0),
  )
}

///|
test "order_resolve_conflicts ignores unrelated edges" {
  let cg = Graph::new()
  let input = [
    order_bary_entry("a", barycenter=Some(2.0), weight=Some(3.0)),
    order_bary_entry("b", barycenter=Some(1.0), weight=Some(2.0)),
  ]
  cg.set_edge("c", "d")
  let out = order_resolve_conflicts(input, cg)
  out.sort_by(order_resolve_conflicts_sort_by_first_vs)
  assert_eq(out.length(), 2)
  order_resolve_conflicts_assert_entry(out[0], ["a"], 0, Some(2.0), Some(3.0))
  order_resolve_conflicts_assert_entry(out[1], ["b"], 1, Some(1.0), Some(2.0))
}

///|
test "order_resolve_conflicts keeps merged zero-weight entries sortable" {
  let cg = Graph::new()
  let input = [
    order_bary_entry("a"),
    order_bary_entry("b"),
    order_bary_entry("c"),
  ]
  cg.set_edge("a", "b")
  let out = order_resolve_conflicts(input, cg)
  let sorted = order_sort(out)
  assert_eq(sorted.vs, ["a", "b", "c"])
  assert_eq(sorted.barycenter, None)
  assert_eq(sorted.weight, None)
}

///|
fn order_resolve_conflicts_sort_by_first_vs(
  a : OrderEntry,
  b : OrderEntry,
) -> Int {
  order_resolve_conflicts_str_cmp(a.vs[0], b.vs[0])
}

///|
fn order_resolve_conflicts_assert_entry(
  entry : OrderEntry,
  vs : Array[String],
  i : Int,
  barycenter : Double?,
  weight : Double?,
) -> Unit raise {
  assert_eq(entry.vs, vs)
  assert_eq(entry.i, i)
  order_resolve_conflicts_assert_opt_double(entry.barycenter, barycenter)
  order_resolve_conflicts_assert_opt_double(entry.weight, weight)
}

///|
fn order_resolve_conflicts_assert_opt_double(
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

///|
fn order_resolve_conflicts_str_cmp(a : String, b : String) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

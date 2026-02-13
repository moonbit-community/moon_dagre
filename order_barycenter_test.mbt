///|
// Upstream: dagre-reference/test/order/barycenter-test.js
test "order_barycenter assigns undefined barycenter for node without predecessors" {
  let g = order_barycenter_graph()
  g.set_node("x", label=empty_attrs())
  let results = order_barycenter(g, movable=["x"])
  assert_eq(results.length(), 1)
  order_barycenter_assert_entry(results[0], "x", None, None)
}

///|
test "order_barycenter assigns position of sole predecessor" {
  let g = order_barycenter_graph()
  let a = empty_attrs()
  a.set_int("order", 2)
  g.set_node("a", label=a)
  g.set_edge("a", "x")
  let results = order_barycenter(g, movable=["x"])
  assert_eq(results.length(), 1)
  order_barycenter_assert_entry(results[0], "x", Some(2.0), Some(1.0))
}

///|
test "order_barycenter assigns average of multiple predecessors" {
  let g = order_barycenter_graph()
  let a = empty_attrs()
  a.set_int("order", 2)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_int("order", 4)
  g.set_node("b", label=b)
  g.set_edge("a", "x")
  g.set_edge("b", "x")
  let results = order_barycenter(g, movable=["x"])
  assert_eq(results.length(), 1)
  order_barycenter_assert_entry(results[0], "x", Some(3.0), Some(2.0))
}

///|
test "order_barycenter uses edge weights" {
  let g = order_barycenter_graph()
  let a = empty_attrs()
  a.set_int("order", 2)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_int("order", 4)
  g.set_node("b", label=b)
  let e1 = empty_attrs()
  e1.set_int("weight", 3)
  g.set_edge("a", "x", label=attrs_value(e1))
  g.set_edge("b", "x")
  let results = order_barycenter(g, movable=["x"])
  assert_eq(results.length(), 1)
  order_barycenter_assert_entry(results[0], "x", Some(2.5), Some(4.0))
}

///|
test "order_barycenter calculates for all movable nodes" {
  let g = order_barycenter_graph()
  let a = empty_attrs()
  a.set_int("order", 1)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_int("order", 2)
  g.set_node("b", label=b)
  let c = empty_attrs()
  c.set_int("order", 4)
  g.set_node("c", label=c)
  g.set_edge("a", "x")
  g.set_edge("b", "x")
  g.set_node("y")
  let ex = empty_attrs()
  ex.set_int("weight", 2)
  g.set_edge("a", "z", label=attrs_value(ex))
  g.set_edge("c", "z")
  let results = order_barycenter(g, movable=["x", "y", "z"])
  assert_eq(results.length(), 3)
  order_barycenter_assert_entry(results[0], "x", Some(1.5), Some(2.0))
  order_barycenter_assert_entry(results[1], "y", None, None)
  order_barycenter_assert_entry(results[2], "z", Some(2.0), Some(3.0))
}

///|
fn order_barycenter_graph() -> Graph {
  let g = Graph::new()
  g.set_default_edge_label(() => {
    let edge = empty_attrs()
    edge.set_int("weight", 1)
    attrs_value(edge)
  })
  g
}

///|
fn order_barycenter_assert_entry(
  entry : OrderBarycenterEntry,
  v : String,
  barycenter : Double?,
  weight : Double?,
) -> Unit raise {
  assert_eq(entry.v, v)
  order_barycenter_assert_opt_double(entry.barycenter, barycenter)
  order_barycenter_assert_opt_double(entry.weight, weight)
}

///|
fn order_barycenter_assert_opt_double(
  actual : Double?,
  expected : Double?,
) -> Unit raise {
  if actual is Some(actual) && expected is Some(expected) {
    assert_eq(order_barycenter_close(actual, expected), true)
  } else {
    assert_eq(actual, expected)
  }
}

///|
fn order_barycenter_close(a : Double, b : Double) -> Bool {
  let diff = if a > b { a - b } else { b - a }
  diff < 0.000000001
}

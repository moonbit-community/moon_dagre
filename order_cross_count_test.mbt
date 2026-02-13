///|
// Upstream: dagre-reference/test/order/cross-count-test.js
test "order_cross_count returns 0 for empty layering" {
  let g = order_cross_graph()
  assert_eq(order_cross_count(g, []).to_int(), 0)
}

///|
test "order_cross_count returns 0 for layering without crossings" {
  let g = order_cross_graph()
  g.set_edge("a1", "b1")
  g.set_edge("a2", "b2")
  assert_eq(order_cross_count(g, [["a1", "a2"], ["b1", "b2"]]).to_int(), 0)
}

///|
test "order_cross_count returns 1 for one crossing" {
  let g = order_cross_graph()
  g.set_edge("a1", "b1")
  g.set_edge("a2", "b2")
  assert_eq(order_cross_count(g, [["a1", "a2"], ["b2", "b1"]]).to_int(), 1)
}

///|
test "order_cross_count returns weighted crossing count" {
  let g = order_cross_graph()
  g.set_edge("a1", "b1", label=order_cross_weight(2))
  g.set_edge("a2", "b2", label=order_cross_weight(3))
  assert_eq(order_cross_count(g, [["a1", "a2"], ["b2", "b1"]]).to_int(), 6)
}

///|
test "order_cross_count calculates crossings across layers" {
  let g = order_cross_graph()
  g.set_path(["a1", "b1", "c1"])
  g.set_path(["a2", "b2", "c2"])
  assert_eq(
    order_cross_count(g, [["a1", "a2"], ["b2", "b1"], ["c1", "c2"]]).to_int(),
    2,
  )
}

///|
test "order_cross_count works for reference graph #1" {
  let g = order_cross_graph()
  g.set_path(["a", "b", "c"])
  g.set_path(["d", "e", "c"])
  g.set_path(["a", "f", "i"])
  g.set_edge("a", "e")
  assert_eq(
    order_cross_count(g, [["a", "d"], ["b", "e", "f"], ["c", "i"]]).to_int(),
    1,
  )
  assert_eq(
    order_cross_count(g, [["d", "a"], ["e", "b", "f"], ["c", "i"]]).to_int(),
    0,
  )
}

///|
fn order_cross_graph() -> Graph {
  let g = Graph::new()
  g.set_default_edge_label(() => order_cross_weight(1))
  g
}

///|
fn order_cross_weight(weight : Int) -> Value {
  let attrs = empty_attrs()
  attrs.set_int("weight", weight)
  attrs_value(attrs)
}

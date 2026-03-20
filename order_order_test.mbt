///|
// Upstream: dagre-reference/test/order/order-test.js
test "order_run does not add crossings to tree structure" {
  let g = order_order_graph()
  g.set_node("a", label=order_order_rank(1))
  for v in ["b", "e"] {
    g.set_node(v, label=order_order_rank(2))
  }
  for v in ["c", "d", "f"] {
    g.set_node(v, label=order_order_rank(3))
  }
  g.set_path(["a", "b", "c"])
  g.set_edge("b", "d")
  g.set_path(["a", "e", "f"])
  order_run(g)
  let layering = build_layer_matrix(g)
  assert_eq(order_cross_count(g, layering).to_int(), 0)
}

///|
test "order_run can solve simple graph" {
  let g = order_order_graph()
  for v in ["a", "d"] {
    g.set_node(v, label=order_order_rank(1))
  }
  for v in ["b", "f", "e"] {
    g.set_node(v, label=order_order_rank(2))
  }
  for v in ["c", "g"] {
    g.set_node(v, label=order_order_rank(3))
  }
  order_run(g)
  let layering = build_layer_matrix(g)
  assert_eq(order_cross_count(g, layering).to_int(), 0)
}

///|
test "order_run can minimize crossings" {
  let g = order_order_graph()
  g.set_node("a", label=order_order_rank(1))
  for v in ["b", "e", "g"] {
    g.set_node(v, label=order_order_rank(2))
  }
  for v in ["c", "f", "h"] {
    g.set_node(v, label=order_order_rank(3))
  }
  g.set_node("d", label=order_order_rank(4))
  order_run(g)
  let layering = build_layer_matrix(g)
  assert_eq(order_cross_count(g, layering) <= 1.0, true)
}

///|
fn order_order_graph() -> Graph {
  let g = Graph::new()
  g.set_default_edge_label(() => {
    let attrs = empty_attrs()
    attrs.set_int("weight", 1)
    attrs_value(attrs)
  })
  g
}

///|
fn order_order_rank(rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs
}

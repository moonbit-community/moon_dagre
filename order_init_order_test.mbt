///|
// Upstream: dagre-reference/test/order/init-order-test.js
test "order_init_order assigns non-overlapping orders for each rank in tree" {
  let g = order_init_graph()
  g.set_node("a", label=order_init_rank(0))
  g.set_node("b", label=order_init_rank(1))
  g.set_node("c", label=order_init_rank(2))
  g.set_node("d", label=order_init_rank(2))
  g.set_node("e", label=order_init_rank(1))
  g.set_path(["a", "b", "c"])
  g.set_edge("b", "d")
  g.set_edge("a", "e")
  let layering = order_init_order(g)
  assert_eq(layering[0], ["a"])
  let l1 = layering[1].copy()
  l1.sort()
  inspect(l1, content="[\"b\", \"e\"]")
  let l2 = layering[2].copy()
  l2.sort()
  inspect(l2, content="[\"c\", \"d\"]")
}

///|
test "order_init_order assigns non-overlapping orders for each rank in DAG" {
  let g = order_init_graph()
  g.set_node("a", label=order_init_rank(0))
  g.set_node("b", label=order_init_rank(1))
  g.set_node("c", label=order_init_rank(1))
  g.set_node("d", label=order_init_rank(2))
  g.set_path(["a", "b", "d"])
  g.set_path(["a", "c", "d"])
  let layering = order_init_order(g)
  assert_eq(layering[0], ["a"])
  let l1 = layering[1].copy()
  l1.sort()
  inspect(l1, content="[\"b\", \"c\"]")
  assert_eq(layering[2], ["d"])
}

///|
test "order_init_order does not assign order to subgraph nodes" {
  let g = order_init_graph()
  g.set_node("a", label=order_init_rank(0))
  g.set_node("sg1", label=empty_attrs())
  g.set_parent("a", parent="sg1")
  let layering = order_init_order(g)
  inspect(layering, content="[[\"a\"]]")
}

///|
fn order_init_graph() -> Graph {
  let g = Graph::new(compound=true)
  g.set_default_edge_label(() => {
    let attrs = empty_attrs()
    attrs.set_int("weight", 1)
    attrs_value(attrs)
  })
  g
}

///|
fn order_init_rank(rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs
}

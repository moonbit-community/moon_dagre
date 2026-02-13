///|
// Upstream: dagre-reference/test/order/build-layer-graph-test.js
test "order_build_layer_graph places rootless movable nodes under root" {
  let g = order_build_layer_fixture()
  g.set_node("a", label=order_build_rank(1))
  g.set_node("b", label=order_build_rank(1))
  g.set_node("c", label=order_build_rank(2))
  g.set_node("d", label=order_build_rank(3))
  let lg = order_build_layer_graph(g, 1, "inEdges")
  let root = lg.graph().get_string_or("root", "")
  assert_eq(lg.has_node(root), true)
  let top = lg.children()
  top.sort()
  assert_eq(top, [root])
  let root_children = lg.children(v=root)
  root_children.sort()
  inspect(root_children, content="[\"a\", \"b\"]")
}

///|
test "order_build_layer_graph copies flat rank nodes" {
  let g = order_build_layer_fixture()
  g.set_node("a", label=order_build_rank(1))
  g.set_node("b", label=order_build_rank(1))
  g.set_node("c", label=order_build_rank(2))
  g.set_node("d", label=order_build_rank(3))
  assert_eq(order_build_layer_graph(g, 1, "inEdges").has_node("a"), true)
  assert_eq(order_build_layer_graph(g, 1, "inEdges").has_node("b"), true)
  assert_eq(order_build_layer_graph(g, 2, "inEdges").has_node("c"), true)
  assert_eq(order_build_layer_graph(g, 3, "inEdges").has_node("d"), true)
}

///|
test "order_build_layer_graph uses original node label for copied nodes" {
  let g = order_build_layer_fixture()
  let a = order_build_rank(1)
  a.set_string("foo", "1")
  g.set_node("a", label=a)
  let b = order_build_rank(2)
  b.set_string("foo", "2")
  g.set_node("b", label=b)
  g.set_edge("a", "b", label=order_build_edge_weight(1))
  let lg = order_build_layer_graph(g, 2, "inEdges")
  assert_eq(lg.node("a").get_string_or("foo", ""), "1")
  g.node("a").set_string("foo", "updated")
  assert_eq(lg.node("a").get_string_or("foo", ""), "updated")
  assert_eq(lg.node("b").get_string_or("foo", ""), "2")
  g.node("b").set_string("foo", "updated")
  assert_eq(lg.node("b").get_string_or("foo", ""), "updated")
}

///|
test "order_build_layer_graph copies incident edges for inEdges" {
  let g = order_build_layer_fixture()
  g.set_node("a", label=order_build_rank(1))
  g.set_node("b", label=order_build_rank(1))
  g.set_node("c", label=order_build_rank(2))
  g.set_node("d", label=order_build_rank(3))
  g.set_edge("a", "c", label=order_build_edge_weight(2))
  g.set_edge("b", "c", label=order_build_edge_weight(3))
  g.set_edge("c", "d", label=order_build_edge_weight(4))
  let l1 = order_build_layer_graph(g, 1, "inEdges")
  let l2 = order_build_layer_graph(g, 2, "inEdges")
  let l3 = order_build_layer_graph(g, 3, "inEdges")
  assert_eq(l1.edge_count(), 0)
  assert_eq(l2.edge_count(), 2)
  assert_eq(
    order_build_edge_attrs(l2.edge("a", "c")).get_float_or("weight", -1.0),
    2.0,
  )
  assert_eq(
    order_build_edge_attrs(l2.edge("b", "c")).get_float_or("weight", -1.0),
    3.0,
  )
  assert_eq(l3.edge_count(), 1)
  assert_eq(
    order_build_edge_attrs(l3.edge("c", "d")).get_float_or("weight", -1.0),
    4.0,
  )
}

///|
test "order_build_layer_graph copies incident edges for outEdges" {
  let g = order_build_layer_fixture()
  g.set_node("a", label=order_build_rank(1))
  g.set_node("b", label=order_build_rank(1))
  g.set_node("c", label=order_build_rank(2))
  g.set_node("d", label=order_build_rank(3))
  g.set_edge("a", "c", label=order_build_edge_weight(2))
  g.set_edge("b", "c", label=order_build_edge_weight(3))
  g.set_edge("c", "d", label=order_build_edge_weight(4))
  let l1 = order_build_layer_graph(g, 1, "outEdges")
  let l2 = order_build_layer_graph(g, 2, "outEdges")
  let l3 = order_build_layer_graph(g, 3, "outEdges")
  assert_eq(l1.edge_count(), 2)
  assert_eq(
    order_build_edge_attrs(l1.edge("c", "a")).get_float_or("weight", -1.0),
    2.0,
  )
  assert_eq(
    order_build_edge_attrs(l1.edge("c", "b")).get_float_or("weight", -1.0),
    3.0,
  )
  assert_eq(l2.edge_count(), 1)
  assert_eq(
    order_build_edge_attrs(l2.edge("d", "c")).get_float_or("weight", -1.0),
    4.0,
  )
  assert_eq(l3.edge_count(), 0)
}

///|
test "order_build_layer_graph collapses multi-edges" {
  let g = order_build_layer_fixture()
  g.set_node("a", label=order_build_rank(1))
  g.set_node("b", label=order_build_rank(2))
  g.set_edge("a", "b", label=order_build_edge_weight(2))
  g.set_edge("a", "b", label=order_build_edge_weight(3), name="multi")
  let l2 = order_build_layer_graph(g, 2, "inEdges")
  assert_eq(
    order_build_edge_attrs(l2.edge("a", "b")).get_float_or("weight", -1.0),
    5.0,
  )
}

///|
test "order_build_layer_graph preserves hierarchy for movable layer" {
  let g = order_build_layer_fixture()
  g.set_node("a", label=order_build_rank(0))
  g.set_node("b", label=order_build_rank(0))
  g.set_node("c", label=order_build_rank(0))
  let sg = empty_attrs()
  sg.set_int("minRank", 0)
  sg.set_int("maxRank", 0)
  sg.set_strings("borderLeft", ["bl"])
  sg.set_strings("borderRight", ["br"])
  g.set_node("sg", label=sg)
  for v in ["a", "b"] {
    g.set_parent(v, parent="sg")
  }
  let lg = order_build_layer_graph(g, 0, "inEdges")
  let root = lg.graph().get_string_or("root", "")
  let root_children = lg.children(v=root)
  root_children.sort()
  inspect(root_children, content="[\"c\", \"sg\"]")
  assert_eq(lg.parent("a"), Some("sg"))
  assert_eq(lg.parent("b"), Some("sg"))
}

///|
fn order_build_layer_fixture() -> Graph {
  Graph::new(compound=true, multigraph=true)
}

///|
fn order_build_rank(rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs
}

///|
fn order_build_edge_weight(weight : Int) -> Value {
  let attrs = empty_attrs()
  attrs.set_int("weight", weight)
  attrs_value(attrs)
}

///|
fn order_build_edge_attrs(label : Value?) -> Attrs {
  if value_as_attrs(label) is Some(attrs) {
    attrs
  } else {
    empty_attrs()
  }
}

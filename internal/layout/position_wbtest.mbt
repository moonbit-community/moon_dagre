///|
// Upstream: dagre-reference/test/position-test.js
test "position respects ranksep" {
  let g = position_fixture()
  g.graph().set_float("ranksep", 1000.0)
  g.set_node("a", label=position_node(50.0, 100.0, 0, 0))
  g.set_node("b", label=position_node(50.0, 80.0, 1, 0))
  g.set_edge("a", "b")
  position(g)
  assert_eq(g.node("b").get_float_or("y", -1.0), 100.0 + 1000.0 + 80.0 / 2.0)
}

///|
test "position uses largest height in each rank with ranksep" {
  let g = position_fixture()
  g.graph().set_float("ranksep", 1000.0)
  g.set_node("a", label=position_node(50.0, 100.0, 0, 0))
  g.set_node("b", label=position_node(50.0, 80.0, 0, 1))
  g.set_node("c", label=position_node(50.0, 90.0, 1, 0))
  g.set_edge("a", "c")
  position(g)
  assert_eq(g.node("a").get_float_or("y", -1.0), 50.0)
  assert_eq(g.node("b").get_float_or("y", -1.0), 50.0)
  assert_eq(g.node("c").get_float_or("y", -1.0), 100.0 + 1000.0 + 90.0 / 2.0)
}

///|
test "position respects nodesep" {
  let g = position_fixture()
  g.graph().set_float("nodesep", 1000.0)
  g.set_node("a", label=position_node(50.0, 100.0, 0, 0))
  g.set_node("b", label=position_node(70.0, 80.0, 0, 1))
  position(g)
  let xa = g.node("a").get_float_or("x", -1.0)
  let xb = g.node("b").get_float_or("x", -1.0)
  assert_eq(xb, xa + 50.0 / 2.0 + 1000.0 + 70.0 / 2.0)
}

///|
test "position does not position subgraph node itself" {
  let g = position_fixture()
  g.set_node("a", label=position_node(50.0, 50.0, 0, 0))
  g.set_node("sg1", label=empty_attrs())
  g.set_parent("a", parent="sg1")
  position(g)
  assert_eq(g.node("sg1").get_float("x"), None)
  assert_eq(g.node("sg1").get_float("y"), None)
}

///|
fn position_fixture() -> Graph {
  let g = Graph::new(compound=true)
  let graph = empty_attrs()
  graph.set_float("ranksep", 50.0)
  graph.set_float("nodesep", 50.0)
  graph.set_float("edgesep", 10.0)
  g.set_graph(graph)
  g
}

///|
fn position_node(
  width : Double,
  height : Double,
  rank : Int,
  order : Int,
) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_float("width", width)
  attrs.set_float("height", height)
  attrs.set_int("rank", rank)
  attrs.set_int("order", order)
  attrs
}

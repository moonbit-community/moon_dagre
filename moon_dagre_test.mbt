///|
// Upstream: dagre-reference/test/layout-test.js
test "moon_dagre layout sets node coordinates" {
  let g = new_graph()
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  ignore(layout(g))
  assert_eq(g.node("a").get_float_or("x", -1.0), 25.0)
  assert_eq(g.node("a").get_float_or("y", -1.0), 50.0)
}

///|
test "moon_dagre layout sets edge points" {
  let g = new_graph()
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 50.0)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_float("width", 50.0)
  b.set_float("height", 50.0)
  g.set_node("b", label=b)
  g.set_edge("a", "b")
  ignore(layout(g))
  let edge = if value_as_attrs(g.edge("a", "b")) is Some(edge) {
    edge
  } else {
    empty_attrs()
  }
  assert_eq(edge.get_points("points") is Some(_), true)
  if edge.get_points("points") is Some(points) {
    assert_eq(points.length() >= 2, true)
  }
}

///|
test "moon_dagre layout threads order constraints through full pipeline" {
  let left_to_right = moon_dagre_constraint_fixture()
  ignore(layout(left_to_right, constraints=[order_constraint("a", "b")]))
  assert_eq(
    left_to_right.node("a").get_int_or("order", -1) <
    left_to_right.node("b").get_int_or("order", -1),
    true,
  )
  assert_eq(
    left_to_right.node("a").get_float_or("x", -1.0) <
    left_to_right.node("b").get_float_or("x", -1.0),
    true,
  )

  let right_to_left = moon_dagre_constraint_fixture()
  ignore(layout(right_to_left, constraints=[order_constraint("b", "a")]))
  assert_eq(
    right_to_left.node("b").get_int_or("order", -1) <
    right_to_left.node("a").get_int_or("order", -1),
    true,
  )
  assert_eq(
    right_to_left.node("b").get_float_or("x", -1.0) <
    right_to_left.node("a").get_float_or("x", -1.0),
    true,
  )
}

///|
test "moon_dagre layout matches dagre-reference for constrained compound with trailing node" {
  let g = moon_dagre_three_child_constraint_fixture()
  ignore(layout(g, constraints=[order_constraint("a", "b")]))
  assert_eq(g.node("a").get_int_or("order", -1), 1)
  assert_eq(g.node("b").get_int_or("order", -1), 2)
  assert_eq(g.node("c").get_int_or("order", -1), 3)
  assert_eq(g.node("a").get_float_or("x", -1.0), 40.0)
  assert_eq(g.node("b").get_float_or("x", -1.0), 120.0)
  assert_eq(g.node("c").get_float_or("x", -1.0), 205.0)
  assert_eq(g.node("sg").get_float_or("x", -1.0), 125.0)
  assert_eq(g.node("sg").get_float_or("y", -1.0), 145.0)
  assert_eq(g.node("sg").get_float_or("width", -1.0), 250.0)
  assert_eq(g.node("sg").get_float_or("height", -1.0), 90.0)
  assert_eq(g.node("src").get_float_or("x", -1.0), 120.0)
  assert_eq(g.node("src").get_float_or("y", -1.0), 25.0)
}

///|
fn moon_dagre_constraint_fixture() -> Graph {
  let g = new_graph(compound=true)
  g.set_graph(empty_attrs())

  let src = empty_attrs()
  src.set_float("width", 50.0)
  src.set_float("height", 50.0)
  g.set_node("src", label=src)

  g.set_node("sg", label=empty_attrs())

  for v in ["a", "b"] {
    let node = empty_attrs()
    node.set_float("width", 50.0)
    node.set_float("height", 50.0)
    g.set_node(v, label=node)
    g.set_parent(v, parent="sg")
    g.set_edge("src", v)
  }

  g
}

///|
fn moon_dagre_three_child_constraint_fixture() -> Graph {
  let g = new_graph(compound=true)
  let graph = empty_attrs()
  graph.set_string("rankdir", "TB")
  graph.set_float("nodesep", 30.0)
  graph.set_float("ranksep", 50.0)
  graph.set_float("edgesep", 10.0)
  graph.set_float("marginx", 0.0)
  graph.set_float("marginy", 0.0)
  g.set_graph(graph)

  let src = empty_attrs()
  src.set_float("width", 50.0)
  src.set_float("height", 50.0)
  g.set_node("src", label=src)
  g.set_node("sg", label=empty_attrs())

  for entry in [("a", 40.0), ("b", 60.0), ("c", 50.0)] {
    let node = empty_attrs()
    node.set_float("width", entry.1)
    node.set_float("height", 40.0)
    g.set_node(entry.0, label=node)
    g.set_parent(entry.0, parent="sg")
    g.set_edge("src", entry.0)
  }

  g
}

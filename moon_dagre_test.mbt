///|
// Upstream: dagre-reference/test/layout-test.js
test "moon_dagre layout sets node coordinates" {
  let g = @moon_dagre.new_graph()
  g.set_graph(@moon_dagre.empty_attrs())
  let a = @moon_dagre.empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  ignore(@moon_dagre.layout(g))
  assert_eq(g.node("a").get_float_or("x", -1.0), 25.0)
  assert_eq(g.node("a").get_float_or("y", -1.0), 50.0)
}

///|
test "moon_dagre layout sets edge points" {
  let g = @moon_dagre.new_graph()
  g.set_graph(@moon_dagre.empty_attrs())
  let a = @moon_dagre.empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 50.0)
  g.set_node("a", label=a)
  let b = @moon_dagre.empty_attrs()
  b.set_float("width", 50.0)
  b.set_float("height", 50.0)
  g.set_node("b", label=b)
  g.set_edge("a", "b")
  ignore(@moon_dagre.layout(g))
  let edge = if @moon_dagre.value_as_attrs(g.edge("a", "b")) is Some(edge) {
    edge
  } else {
    @moon_dagre.empty_attrs()
  }
  assert_eq(edge.get_points("points") is Some(_), true)
  if edge.get_points("points") is Some(points) {
    assert_eq(points.length() >= 2, true)
  }
}

///|
// Upstream: dagre-reference/test/bundle-test.js
test "bundle exports core api" {
  let g = @moon_dagre.new_graph()
  assert_eq(g.is_directed(), true)
  assert_eq(@moon_dagre.version().length() > 0, true)
}

///|
test "bundle can do trivial layout" {
  let g = @moon_dagre.new_graph()
  g.set_graph(@moon_dagre.empty_attrs())
  let a = @moon_dagre.empty_attrs()
  a.set_string("label", "a")
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  let b = @moon_dagre.empty_attrs()
  b.set_string("label", "b")
  b.set_float("width", 50.0)
  b.set_float("height", 100.0)
  g.set_node("b", label=b)
  let e = @moon_dagre.empty_attrs()
  e.set_string("label", "ab")
  e.set_float("width", 50.0)
  e.set_float("height", 100.0)
  g.set_edge("a", "b", label=@moon_dagre.attrs_value(e))
  ignore(@moon_dagre.layout(g))
  assert_eq(g.node("a").get_float("x") is Some(_), true)
  assert_eq(g.node("a").get_float("y") is Some(_), true)
  assert_eq(g.node("a").get_float_or("x", -1.0) >= 0.0, true)
  assert_eq(g.node("a").get_float_or("y", -1.0) >= 0.0, true)
  let edge = if @moon_dagre.value_as_attrs(g.edge("a", "b")) is Some(edge) {
    edge
  } else {
    @moon_dagre.empty_attrs()
  }
  assert_eq(edge.get_float("x") is Some(_), true)
  assert_eq(edge.get_float("y") is Some(_), true)
  assert_eq(edge.get_float_or("x", -1.0) >= 0.0, true)
  assert_eq(edge.get_float_or("y", -1.0) >= 0.0, true)
}

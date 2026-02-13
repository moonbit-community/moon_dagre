///|
// Upstream: dagre-reference/test/normalize-test.js
test "normalize_run keeps short edge" {
  let g = new_norm_graph()
  g.set_node("a", label=normalize_node_rank(0))
  g.set_node("b", label=normalize_node_rank(1))
  g.set_edge("a", "b", label=attrs_value(empty_attrs()))
  normalize_run(g)
  inspect(edges_to_pairs(g.edges()), content="[\"a->b\"]")
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
}

///|
test "normalize_run splits two-layer edge" {
  let g = new_norm_graph()
  g.set_node("a", label=normalize_node_rank(0))
  g.set_node("b", label=normalize_node_rank(2))
  g.set_edge("a", "b", label=attrs_value(empty_attrs()))
  normalize_run(g)
  let a_succ = g.successors("a")
  assert_eq(a_succ.length(), 1)
  let d = a_succ[0]
  assert_eq(g.node(d).get_string_or("dummy", ""), "edge")
  assert_eq(g.node(d).get_int_or("rank", -1), 1)
  inspect(g.successors(d), content="[\"b\"]")
  let chains = g.graph().get_strings("dummyChains")
  assert_eq(chains is Some(_), true)
  if chains is Some(chains) {
    assert_eq(chains.length(), 1)
    assert_eq(chains[0], d)
  }
}

///|
test "normalize_run assigns default dummy size" {
  let g = new_norm_graph()
  g.set_node("a", label=normalize_node_rank(0))
  g.set_node("b", label=normalize_node_rank(2))
  let edge = empty_attrs()
  edge.set_float("width", 10.0)
  edge.set_float("height", 10.0)
  g.set_edge("a", "b", label=attrs_value(edge))
  normalize_run(g)
  let d = g.successors("a")[0]
  assert_eq(g.node(d).get_float_or("width", -1.0), 0.0)
  assert_eq(g.node(d).get_float_or("height", -1.0), 0.0)
}

///|
test "normalize_run assigns label width/height at labelRank" {
  let g = new_norm_graph()
  g.set_node("a", label=normalize_node_rank(0))
  g.set_node("b", label=normalize_node_rank(4))
  let edge = empty_attrs()
  edge.set_float("width", 20.0)
  edge.set_float("height", 10.0)
  edge.set_int("labelRank", 2)
  g.set_edge("a", "b", label=attrs_value(edge))
  normalize_run(g)
  let label_v = g.successors(g.successors("a")[0])[0]
  let label_node = g.node(label_v)
  assert_eq(label_node.get_float_or("width", -1.0), 20.0)
  assert_eq(label_node.get_float_or("height", -1.0), 10.0)
}

///|
test "normalize_undo restores edge and labels" {
  let g = new_norm_graph()
  g.set_node("a", label=normalize_node_rank(0))
  g.set_node("b", label=normalize_node_rank(2))
  let edge = empty_attrs()
  edge.set_string("foo", "bar")
  g.set_edge("a", "b", label=attrs_value(edge))
  normalize_run(g)
  normalize_undo(g)
  inspect(edges_to_pairs(g.edges()), content="[\"a->b\"]")
  let restored = normalize_edge_attrs(g.edge("a", "b"))
  assert_eq(restored.get_string_or("foo", ""), "bar")
}

///|
test "normalize_undo collects points" {
  let g = new_norm_graph()
  g.set_node("a", label=normalize_node_rank(0))
  g.set_node("b", label=normalize_node_rank(2))
  g.set_edge("a", "b", label=attrs_value(empty_attrs()))
  normalize_run(g)
  let d = g.neighbors("a")[0]
  let dummy = g.node(d)
  dummy.set_float("x", 5.0)
  dummy.set_float("y", 10.0)
  normalize_undo(g)
  let points = normalize_edge_attrs(g.edge("a", "b")).get_points("points")
  assert_eq(points is Some(_), true)
  if points is Some(points) {
    assert_eq(points.length(), 1)
    assert_eq(points[0].x, 5.0)
    assert_eq(points[0].y, 10.0)
  }
}

///|
test "normalize_undo restores multiedges" {
  let g = new_norm_graph()
  g.set_node("a", label=normalize_node_rank(0))
  g.set_node("b", label=normalize_node_rank(2))
  g.set_edge("a", "b", label=attrs_value(empty_attrs()), name="bar")
  g.set_edge("a", "b", label=attrs_value(empty_attrs()), name="foo")
  normalize_run(g)
  let out = g.out_edges("a")
  out.sort_by((a, b) => str_cmp(edge_name(a), edge_name(b)))
  let bar_dummy = g.node(out[0].w)
  bar_dummy.set_float("x", 5.0)
  bar_dummy.set_float("y", 10.0)
  let foo_dummy = g.node(out[1].w)
  foo_dummy.set_float("x", 15.0)
  foo_dummy.set_float("y", 20.0)
  normalize_undo(g)
  assert_eq(g.has_edge("a", "b"), false)
  let bar_points = normalize_edge_attrs(g.edge("a", "b", name="bar")).get_points(
    "points",
  )
  let foo_points = normalize_edge_attrs(g.edge("a", "b", name="foo")).get_points(
    "points",
  )
  assert_eq(bar_points is Some(_), true)
  assert_eq(foo_points is Some(_), true)
}

///|
fn new_norm_graph() -> Graph {
  let g = Graph::new(multigraph=true, compound=true)
  g.set_graph(empty_attrs())
  g
}

///|
fn normalize_node_rank(rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs
}

///|
fn normalize_edge_attrs(label : Value?) -> Attrs {
  if value_as_attrs(label) is Some(attrs) {
    attrs
  } else {
    empty_attrs()
  }
}

///|
fn edges_to_pairs(edges : Array[EdgeObj]) -> Array[String] {
  edges.map(e => "\{e.v}->\{e.w}")
}

///|
fn edge_name(e : EdgeObj) -> String {
  if e.name is Some(name) {
    name
  } else {
    ""
  }
}

///|
fn str_cmp(a : String, b : String) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

///|
// Upstream: dagre-reference/test/order/sort-subgraph-test.js
test "order_sort_subgraph sorts flat subgraph based on barycenter" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  g.set_edge("3", "x")
  let weighted = empty_attrs()
  weighted.set_int("weight", 2)
  g.set_edge("1", "y", label=attrs_value(weighted))
  g.set_edge("4", "y")
  for v in ["x", "y"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg)
  assert_eq(out.vs, ["y", "x"])
}

///|
test "order_sort_subgraph preserves position of node without neighbors" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  g.set_edge("3", "x")
  g.set_node("y")
  let weighted = empty_attrs()
  weighted.set_int("weight", 2)
  g.set_edge("1", "z", label=attrs_value(weighted))
  g.set_edge("4", "z")
  for v in ["x", "y", "z"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg)
  assert_eq(out.vs, ["z", "y", "x"])
}

///|
test "order_sort_subgraph biases left by default" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  g.set_edge("1", "x")
  g.set_edge("1", "y")
  for v in ["x", "y"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg)
  assert_eq(out.vs, ["x", "y"])
}

///|
test "order_sort_subgraph biases right when requested" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  g.set_edge("1", "x")
  g.set_edge("1", "y")
  for v in ["x", "y"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg, bias_right=true)
  assert_eq(out.vs, ["y", "x"])
}

///|
test "order_sort_subgraph aggregates subgraph stats" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  g.set_edge("3", "x")
  let weighted = empty_attrs()
  weighted.set_int("weight", 2)
  g.set_edge("1", "y", label=attrs_value(weighted))
  g.set_edge("4", "y")
  for v in ["x", "y"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg)
  order_sort_subgraph_assert_opt_double(out.barycenter, Some(2.25))
  order_sort_subgraph_assert_opt_double(out.weight, Some(4.0))
}

///|
test "order_sort_subgraph handles nested subgraph without barycenter" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  for v in ["a", "b", "c"] {
    g.set_node(v)
    g.set_parent(v, parent="y")
  }
  g.set_edge("0", "x")
  g.set_edge("1", "z")
  g.set_edge("2", "y")
  for v in ["x", "y", "z"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg)
  assert_eq(out.vs, ["x", "z", "a", "b", "c"])
}

///|
test "order_sort_subgraph handles nested subgraph with barycenter" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  for v in ["a", "b", "c"] {
    g.set_node(v)
    g.set_parent(v, parent="y")
  }
  let w3 = empty_attrs()
  w3.set_int("weight", 3)
  g.set_edge("0", "a", label=attrs_value(w3))
  g.set_edge("0", "x")
  g.set_edge("1", "z")
  g.set_edge("2", "y")
  for v in ["x", "y", "z"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg)
  assert_eq(out.vs, ["x", "a", "b", "c", "z"])
}

///|
test "order_sort_subgraph handles nested subgraph with no in-edges" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  for v in ["a", "b", "c"] {
    g.set_node(v)
    g.set_parent(v, parent="y")
  }
  g.set_edge("0", "a")
  g.set_edge("1", "b")
  g.set_edge("0", "x")
  g.set_edge("1", "z")
  for v in ["x", "y", "z"] {
    g.set_parent(v, parent="movable")
  }
  let out = order_sort_subgraph(g, "movable", cg)
  assert_eq(out.vs, ["x", "a", "b", "c", "z"])
}

///|
test "order_sort_subgraph keeps border nodes at extremes" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  g.set_edge("0", "x")
  g.set_edge("1", "y")
  g.set_edge("2", "z")
  let sg1 = empty_attrs()
  sg1.set_string("borderLeft", "bl")
  sg1.set_string("borderRight", "br")
  g.set_node("sg1", label=sg1)
  for v in ["x", "y", "z", "bl", "br"] {
    g.set_parent(v, parent="sg1")
  }
  let out = order_sort_subgraph(g, "sg1", cg)
  assert_eq(out.vs, ["bl", "x", "y", "z", "br"])
}

///|
test "order_sort_subgraph assigns barycenter from previous border nodes" {
  let g = order_sort_subgraph_graph()
  let cg = Graph::new()
  let bl1 = empty_attrs()
  bl1.set_int("order", 0)
  g.set_node("bl1", label=bl1)
  let br1 = empty_attrs()
  br1.set_int("order", 1)
  g.set_node("br1", label=br1)
  g.set_edge("bl1", "bl2")
  g.set_edge("br1", "br2")
  for v in ["bl2", "br2"] {
    g.set_parent(v, parent="sg")
  }
  let sg = empty_attrs()
  sg.set_string("borderLeft", "bl2")
  sg.set_string("borderRight", "br2")
  g.set_node("sg", label=sg)
  let out = order_sort_subgraph(g, "sg", cg)
  assert_eq(out.vs, ["bl2", "br2"])
  order_sort_subgraph_assert_opt_double(out.barycenter, Some(0.5))
  order_sort_subgraph_assert_opt_double(out.weight, Some(2.0))
}

///|
fn order_sort_subgraph_graph() -> Graph {
  let g = Graph::new(compound=true)
  g.set_default_edge_label(() => {
    let attrs = empty_attrs()
    attrs.set_int("weight", 1)
    attrs_value(attrs)
  })
  for i in 0..<5 {
    let attrs = empty_attrs()
    attrs.set_int("order", i)
    g.set_node(i.to_string(), label=attrs)
  }
  g
}

///|
fn order_sort_subgraph_assert_opt_double(
  actual : Double?,
  expected : Double?,
) -> Unit raise {
  if actual is Some(actual) && expected is Some(expected) {
    let diff = if actual > expected {
      actual - expected
    } else {
      expected - actual
    }
    assert_eq(diff < 0.000000001, true)
  } else {
    assert_eq(actual, expected)
  }
}

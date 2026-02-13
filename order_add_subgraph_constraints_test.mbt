///|
// Upstream: dagre-reference/test/order/add-subgraph-constraints-test.js
test "order_add_subgraph_constraints does not change CG for flat nodes" {
  let g = Graph::new(compound=true)
  let cg = Graph::new()
  let vs = ["a", "b", "c", "d"]
  for v in vs {
    g.set_node(v)
  }
  order_add_subgraph_constraints(g, cg, vs)
  assert_eq(cg.node_count(), 0)
  assert_eq(cg.edge_count(), 0)
}

///|
test "order_add_subgraph_constraints does not create constraint for contiguous subgraph nodes" {
  let g = Graph::new(compound=true)
  let cg = Graph::new()
  let vs = ["a", "b", "c"]
  for v in vs {
    g.set_parent(v, parent="sg")
  }
  order_add_subgraph_constraints(g, cg, vs)
  assert_eq(cg.node_count(), 0)
  assert_eq(cg.edge_count(), 0)
}

///|
test "order_add_subgraph_constraints adds constraint for adjacent nodes with different parents" {
  let g = Graph::new(compound=true)
  let cg = Graph::new()
  let vs = ["a", "b"]
  g.set_parent("a", parent="sg1")
  g.set_parent("b", parent="sg2")
  order_add_subgraph_constraints(g, cg, vs)
  inspect(order_add_constraints_edge_strings(cg), content="[\"sg1->sg2\"]")
}

///|
test "order_add_subgraph_constraints works for multiple levels" {
  let g = Graph::new(compound=true)
  let cg = Graph::new()
  let vs = ["a", "b", "c", "d", "e", "f", "g", "h"]
  for v in vs {
    g.set_node(v)
  }
  g.set_parent("b", parent="sg2")
  g.set_parent("sg2", parent="sg1")
  g.set_parent("c", parent="sg1")
  g.set_parent("d", parent="sg3")
  g.set_parent("sg3", parent="sg1")
  g.set_parent("f", parent="sg4")
  g.set_parent("g", parent="sg5")
  g.set_parent("sg5", parent="sg4")
  order_add_subgraph_constraints(g, cg, vs)
  inspect(
    order_add_constraints_edge_strings(cg),
    content="[\"sg1->sg4\", \"sg2->sg3\"]",
  )
}

///|
fn order_add_constraints_edge_strings(g : Graph) -> Array[String] {
  let out = g.edges().map(e => "\{e.v}->\{e.w}")
  out.sort()
  out
}

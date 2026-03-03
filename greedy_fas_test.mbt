///|
// Upstream: dagre-reference/test/greedy-fas-test.js
test "greedy_fas returns empty for empty graph" {
  let g = Graph::new()
  inspect(edges_to_strings(greedy_fas(g)), content="[]")
}

///|
test "greedy_fas returns empty for acyclic graph" {
  let g = Graph::new()
  g.set_edge("a", "b")
  g.set_edge("b", "c")
  g.set_edge("b", "d")
  g.set_edge("a", "e")
  inspect(edges_to_strings(greedy_fas(g)), content="[]")
}

///|
test "greedy_fas breaks simple cycle" {
  let g = Graph::new()
  g.set_edge("a", "b")
  g.set_edge("b", "a")
  let fas = greedy_fas(g)
  assert_eq(check_fas(g, fas), true)
}

///|
test "greedy_fas works with edge weights" {
  let g1 = Graph::new()
  g1.set_edge("n1", "n2", label=value_float(2.0))
  g1.set_edge("n2", "n1", label=value_float(1.0))
  let fas1 = greedy_fas(g1, weight_fn=edge_weight_fn(g1))
  inspect(edges_to_strings(fas1), content="[\"n2->n1\"]")
  let g2 = Graph::new()
  g2.set_edge("n1", "n2", label=value_float(1.0))
  g2.set_edge("n2", "n1", label=value_float(2.0))
  let fas2 = greedy_fas(g2, weight_fn=edge_weight_fn(g2))
  inspect(edges_to_strings(fas2), content="[\"n1->n2\"]")
}

///|
test "greedy_fas works with multigraph" {
  let g = Graph::new(multigraph=true)
  g.set_edge("a", "b", label=value_float(5.0), name="foo")
  g.set_edge("b", "a", label=value_float(2.0), name="bar")
  g.set_edge("b", "a", label=value_float(2.0), name="baz")
  let fas = greedy_fas(g, weight_fn=edge_weight_fn(g))
  let sorted = edges_to_strings(fas)
  sorted.sort()
  inspect(sorted, content="[\"b->a#bar\", \"b->a#baz\"]")
}

///|
fn check_fas(g : Graph, fas : Array[EdgeObj]) -> Bool {
  for edge in fas {
    let name = edge.name
    g.remove_edge(edge.v, edge.w, name?)
  }
  find_cycles(g).is_empty()
}

///|
fn edge_weight_fn(g : Graph) -> (EdgeObj) -> Double {
  (e : EdgeObj) => {
    if value_as_float(g.edge_obj(e)) is Some(v) {
      v
    } else if value_as_int(g.edge_obj(e)) is Some(v) {
      v.to_double()
    } else if value_as_attrs(g.edge_obj(e)) is Some(attrs) {
      attrs.get_float_or("weight", 1.0)
    } else {
      1.0
    }
  }
}

///|
fn edges_to_strings(edges : Array[EdgeObj]) -> Array[String] {
  edges.map(edge_to_string)
}

///|
fn edge_to_string(e : EdgeObj) -> String {
  if e.name is Some(name) {
    "\{e.v}->\{e.w}#\{name}"
  } else {
    "\{e.v}->\{e.w}"
  }
}

///|
// Upstream: dagre-reference/test/acyclic-test.js
test "acyclic_run keeps acyclic graph unchanged" {
  let g = new_acyclic_graph()
  g.set_path(["a", "b", "d"])
  g.set_path(["a", "c", "d"])
  acyclic_run(g)
  let edges = acyclic_edges_to_strings(g.edges())
  edges.sort()
  inspect(edges, content="[\"a->b\", \"a->c\", \"b->d\", \"c->d\"]")
}

///|
test "acyclic_run breaks cycles" {
  let g = new_acyclic_graph()
  g.set_path(["a", "b", "c", "d", "a"])
  acyclic_run(g)
  inspect(find_cycles(g), content="[]")
}

///|
test "acyclic_run creates multiedges when needed" {
  let g = new_acyclic_graph()
  g.set_path(["a", "b", "a"])
  acyclic_run(g)
  assert_eq(find_cycles(g).is_empty(), true)
  let ab = g.out_edges("a", w="b").length()
  let ba = g.out_edges("b", w="a").length()
  assert_eq(ab == 2 || ba == 2, true)
  assert_eq(g.edge_count(), 2)
}

///|
test "acyclic_undo restores reversed edges" {
  let g = new_acyclic_graph()
  g.set_edge("a", "b", label=attrs_value(edge_label(minlen=2, weight=3)))
  g.set_edge("b", "a", label=attrs_value(edge_label(minlen=3, weight=4)))
  acyclic_run(g)
  acyclic_undo(g)
  let ab = acyclic_edge_attrs(g, "a", "b")
  let ba = acyclic_edge_attrs(g, "b", "a")
  assert_eq(ab.get_int_or("minlen", 0), 2)
  assert_eq(ab.get_int_or("weight", 0), 3)
  assert_eq(ba.get_int_or("minlen", 0), 3)
  assert_eq(ba.get_int_or("weight", 0), 4)
  assert_eq(g.edges().length(), 2)
}

///|
fn new_acyclic_graph() -> Graph {
  let g = Graph::new(multigraph=true)
  g.set_default_edge_label(() => attrs_value(edge_label()))
  g
}

///|
fn edge_label(minlen? : Int = 1, weight? : Int = 1) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("minlen", minlen)
  attrs.set_int("weight", weight)
  attrs
}

///|
fn acyclic_edge_attrs(g : Graph, v : String, w : String) -> Attrs {
  if value_as_attrs(g.edge(v, w)) is Some(attrs) {
    attrs
  } else if value_as_int(g.edge(v, w)) is Some(v) {
    let attrs = empty_attrs()
    attrs.set_int("weight", v)
    attrs
  } else if value_as_float(g.edge(v, w)) is Some(v) {
    let attrs = empty_attrs()
    attrs.set_float("weight", v)
    attrs
  } else {
    empty_attrs()
  }
}

///|
fn acyclic_edges_to_strings(edges : Array[EdgeObj]) -> Array[String] {
  edges.map(acyclic_edge_to_string)
}

///|
fn acyclic_edge_to_string(e : EdgeObj) -> String {
  if e.name is Some(name) {
    "\{e.v}->\{e.w}#\{name}"
  } else {
    "\{e.v}->\{e.w}"
  }
}

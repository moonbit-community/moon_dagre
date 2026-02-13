///|
// Upstream: dagre-reference/test/rank/rank-test.js
test "rank longest-path respects minlen" {
  assert_eq(assert_minlen_respected("longest-path"), true)
}

///|
test "rank tight-tree respects minlen" {
  assert_eq(assert_minlen_respected("tight-tree"), true)
}

///|
test "rank network-simplex respects minlen" {
  assert_eq(assert_minlen_respected("network-simplex"), true)
}

///|
test "rank unknown defaults and respects minlen" {
  assert_eq(assert_minlen_respected("unknown-should-still-work"), true)
}

///|
test "rank can rank single-node graphs" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=empty_attrs())
  rank(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
}

///|
fn assert_minlen_respected(ranker : String) -> Bool {
  let g = new_rank_input_graph()
  g.graph().set_string("ranker", ranker)
  rank(g)
  let mut ok = true
  for e in g.edges() {
    let vrank = g.node(e.v).get_int_or("rank", 0)
    let wrank = g.node(e.w).get_int_or("rank", 0)
    let minlen = edge_attrs_from_value(g.edge_obj(e)).get_int_or("minlen", 1)
    ok = ok && wrank - vrank >= minlen
  }
  ok
}

///|
fn new_rank_input_graph() -> Graph {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_default_edge_label(() => {
    let edge = empty_attrs()
    edge.set_int("minlen", 1)
    edge.set_int("weight", 1)
    attrs_value(edge)
  })
  g.set_path(["a", "b", "c", "d", "h"])
  g.set_path(["a", "e", "g", "h"])
  g.set_path(["a", "f", "g"])
  g
}

///|
fn edge_attrs_from_value(label : Value?) -> Attrs {
  if value_as_attrs(label) is Some(attrs) {
    attrs
  } else {
    empty_attrs()
  }
}

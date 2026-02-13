///|
// Upstream: dagre-reference/test/util-test.js
test "simplify copies graph with no multi-edges" {
  let g = Graph::new(multigraph=true)
  g.set_edge("a", "b", label=util_edge_label(weight=1, minlen=1))
  let g2 = simplify(g)
  let edge = util_edge_attrs(g2.edge("a", "b"))
  assert_eq(edge.get_float_or("weight", -1.0), 1.0)
  assert_eq(edge.get_int_or("minlen", -1), 1)
  assert_eq(g2.edge_count(), 1)
}

///|
test "simplify collapses multi-edges" {
  let g = Graph::new(multigraph=true)
  g.set_edge("a", "b", label=util_edge_label(weight=1, minlen=1))
  g.set_edge("a", "b", label=util_edge_label(weight=2, minlen=2), name="multi")
  let g2 = simplify(g)
  assert_eq(g2.is_multigraph(), false)
  let edge = util_edge_attrs(g2.edge("a", "b"))
  assert_eq(edge.get_float_or("weight", -1.0), 3.0)
  assert_eq(edge.get_int_or("minlen", -1), 2)
  assert_eq(g2.edge_count(), 1)
}

///|
test "simplify copies graph object" {
  let g = Graph::new(multigraph=true)
  let graph = empty_attrs()
  graph.set_string("foo", "bar")
  g.set_graph(graph)
  let g2 = simplify(g)
  assert_eq(g2.graph().get_string_or("foo", ""), "bar")
}

///|
test "as_non_compound_graph copies all nodes" {
  let g = Graph::new(compound=true, multigraph=true)
  let a = empty_attrs()
  a.set_string("foo", "bar")
  g.set_node("a", label=a)
  g.set_node("b")
  let g2 = as_non_compound_graph(g)
  assert_eq(g2.node("a").get_string_or("foo", ""), "bar")
  assert_eq(g2.has_node("b"), true)
}

///|
test "as_non_compound_graph copies all edges" {
  let g = Graph::new(compound=true, multigraph=true)
  let e1 = empty_attrs()
  e1.set_string("foo", "bar")
  g.set_edge("a", "b", label=attrs_value(e1))
  let e2 = empty_attrs()
  e2.set_string("foo", "baz")
  g.set_edge("a", "b", label=attrs_value(e2), name="multi")
  let g2 = as_non_compound_graph(g)
  assert_eq(util_edge_attrs(g2.edge("a", "b")).get_string_or("foo", ""), "bar")
  assert_eq(
    util_edge_attrs(g2.edge("a", "b", name="multi")).get_string_or("foo", ""),
    "baz",
  )
}

///|
test "as_non_compound_graph does not copy compound nodes" {
  let g = Graph::new(compound=true, multigraph=true)
  g.set_parent("a", parent="sg1")
  let g2 = as_non_compound_graph(g)
  assert_eq(g2.has_node("sg1"), false)
  assert_eq(g2.is_compound(), false)
}

///|
test "as_non_compound_graph copies graph object" {
  let g = Graph::new(compound=true, multigraph=true)
  let graph = empty_attrs()
  graph.set_string("foo", "bar")
  g.set_graph(graph)
  let g2 = as_non_compound_graph(g)
  assert_eq(g2.graph().get_string_or("foo", ""), "bar")
}

///|
test "successor_weights maps node to successors with weights" {
  let g = Graph::new(multigraph=true)
  g.set_edge("a", "b", label=util_edge_label(weight=2))
  g.set_edge("b", "c", label=util_edge_label(weight=1))
  g.set_edge("b", "c", label=util_edge_label(weight=2), name="multi")
  g.set_edge("b", "d", label=util_edge_label(weight=1), name="multi")
  let ws = successor_weights(g)
  assert_eq(ws.get_or_default("a", Map::new()).get_or_default("b", 0.0), 2.0)
  assert_eq(ws.get_or_default("b", Map::new()).get_or_default("c", 0.0), 3.0)
  assert_eq(ws.get_or_default("b", Map::new()).get_or_default("d", 0.0), 1.0)
  assert_eq(ws.get_or_default("c", Map::new()).length(), 0)
  assert_eq(ws.get_or_default("d", Map::new()).length(), 0)
}

///|
test "predecessor_weights maps node to predecessors with weights" {
  let g = Graph::new(multigraph=true)
  g.set_edge("a", "b", label=util_edge_label(weight=2))
  g.set_edge("b", "c", label=util_edge_label(weight=1))
  g.set_edge("b", "c", label=util_edge_label(weight=2), name="multi")
  g.set_edge("b", "d", label=util_edge_label(weight=1), name="multi")
  let ws = predecessor_weights(g)
  assert_eq(ws.get_or_default("a", Map::new()).length(), 0)
  assert_eq(ws.get_or_default("b", Map::new()).get_or_default("a", 0.0), 2.0)
  assert_eq(ws.get_or_default("c", Map::new()).get_or_default("b", 0.0), 3.0)
  assert_eq(ws.get_or_default("d", Map::new()).get_or_default("b", 0.0), 1.0)
}

///|
test "intersect_rect computes border intersection" {
  let r = rect(0.0, 0.0, 2.0, 2.0)
  let p = point(6.0, 2.0)
  let cross = intersect_rect(r, p)
  assert_eq(cross.x, 1.0)
  assert_eq(cross.y > -1.0 && cross.y < 1.0, true)
}

///|
test "build_layer_matrix creates matrix from rank and order" {
  let g = Graph::new()
  g.set_node("a", label=util_rank_order(0, 0))
  g.set_node("b", label=util_rank_order(0, 1))
  g.set_node("c", label=util_rank_order(1, 0))
  g.set_node("d", label=util_rank_order(1, 1))
  g.set_node("e", label=util_rank_order(2, 0))
  inspect(
    build_layer_matrix(g),
    content="[[\"a\", \"b\"], [\"c\", \"d\"], [\"e\"]]",
  )
}

///|
test "time returns value from thunk" {
  assert_eq(time("foo", () => "bar"), "bar")
}

///|
test "normalize_ranks shifts ranks so minimum is 0" {
  let g = Graph::new()
  g.set_node("a", label=util_rank(3))
  g.set_node("b", label=util_rank(2))
  g.set_node("c", label=util_rank(4))
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 1)
  assert_eq(g.node("b").get_int_or("rank", -1), 0)
  assert_eq(g.node("c").get_int_or("rank", -1), 2)
}

///|
test "normalize_ranks works for negative ranks" {
  let g = Graph::new()
  g.set_node("a", label=util_rank(-3))
  g.set_node("b", label=util_rank(-2))
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
}

///|
test "normalize_ranks does not assign rank to subgraph nodes" {
  let g = Graph::new(compound=true)
  g.set_node("a", label=util_rank(0))
  g.set_node("sg", label=empty_attrs())
  g.set_parent("a", parent="sg")
  normalize_ranks(g)
  assert_eq(g.node("sg").get_int("rank"), None)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
}

///|
test "remove_empty_ranks removes border-only gaps" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_int("nodeRankFactor", 4)
  g.set_graph(graph)
  g.set_node("a", label=util_rank(0))
  g.set_node("b", label=util_rank(4))
  remove_empty_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
}

///|
test "remove_empty_ranks does not remove non-border ranks" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_int("nodeRankFactor", 4)
  g.set_graph(graph)
  g.set_node("a", label=util_rank(0))
  g.set_node("b", label=util_rank(8))
  remove_empty_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 2)
}

///|
test "remove_empty_ranks handles parents with undefined rank" {
  let g = Graph::new(compound=true)
  let graph = empty_attrs()
  graph.set_int("nodeRankFactor", 3)
  g.set_graph(graph)
  g.set_node("a", label=util_rank(0))
  g.set_node("b", label=util_rank(6))
  g.set_node("sg", label=empty_attrs())
  g.set_parent("a", parent="sg")
  remove_empty_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 2)
  assert_eq(g.node("sg").get_int("rank"), None)
}

///|
test "range builds array to limit" {
  let out = range(4)
  assert_eq(out.length(), 4)
  assert_eq(out[0] + out[1] + out[2] + out[3], 6)
}

///|
test "range builds array with start" {
  let out = range(2, limit=4)
  assert_eq(out.length(), 2)
  assert_eq(out[0] + out[1], 5)
}

///|
test "range builds array with negative step" {
  let out = range(5, limit=-1, step=-1)
  assert_eq(out[0], 5)
  assert_eq(out[5], 0)
}

///|
test "map_values creates map with same keys" {
  let users : Map[String, Int] = Map::new()
  users.set("fred", 40)
  users.set("pebbles", 1)
  let ages = map_values(users, (age, _) => age)
  assert_eq(ages.get_or_default("fred", -1), 40)
  assert_eq(ages.get_or_default("pebbles", -1), 1)
}

///|
fn util_edge_label(weight? : Int = 1, minlen? : Int = 1) -> Value {
  let attrs = empty_attrs()
  attrs.set_int("weight", weight)
  attrs.set_int("minlen", minlen)
  attrs_value(attrs)
}

///|
fn util_edge_attrs(value : Value?) -> Attrs {
  if value_as_attrs(value) is Some(attrs) {
    attrs
  } else {
    empty_attrs()
  }
}

///|
fn util_rank(rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs
}

///|
fn util_rank_order(rank : Int, order : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs.set_int("order", order)
  attrs
}

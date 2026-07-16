///|
// Upstream: dagre-reference/test/rank/util-test.js
test "rank_longest_path assigns rank for single node" {
  let g = new_rank_graph()
  g.set_node("a")
  rank_longest_path(g)
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
}

///|
test "rank_longest_path assigns ranks for unconnected nodes" {
  let g = new_rank_graph()
  g.set_node("a")
  g.set_node("b")
  rank_longest_path(g)
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 0)
}

///|
test "rank_longest_path assigns ranks for connected nodes" {
  let g = new_rank_graph()
  g.set_edge("a", "b")
  rank_longest_path(g)
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
}

///|
test "rank_longest_path assigns ranks for diamond" {
  let g = new_rank_graph()
  g.set_path(["a", "b", "d"])
  g.set_path(["a", "c", "d"])
  rank_longest_path(g)
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
  assert_eq(g.node("c").get_int_or("rank", -1), 1)
  assert_eq(g.node("d").get_int_or("rank", -1), 2)
}

///|
test "rank_longest_path uses edge minlen" {
  let g = new_rank_graph()
  g.set_path(["a", "b", "d"])
  g.set_edge("a", "c")
  let edge = empty_attrs()
  edge.set_int("minlen", 2)
  g.set_edge("c", "d", label=attrs_value(edge))
  rank_longest_path(g)
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 2)
  assert_eq(g.node("c").get_int_or("rank", -1), 1)
  assert_eq(g.node("d").get_int_or("rank", -1), 3)
}

///|
fn new_rank_graph() -> Graph {
  let g = Graph::new()
  g.set_default_edge_label(() => {
    let edge = empty_attrs()
    edge.set_int("minlen", 1)
    attrs_value(edge)
  })
  g
}

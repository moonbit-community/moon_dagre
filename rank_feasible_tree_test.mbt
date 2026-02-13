///|
// Upstream: dagre-reference/test/rank/feasible-tree-test.js
test "rank_feasible_tree handles trivial graph" {
  let g = Graph::new()
  g.set_node("a", label=rank_ft_node_rank(0))
  g.set_node("b", label=rank_ft_node_rank(1))
  g.set_edge("a", "b", label=edge_minlen(1))
  let tree = rank_feasible_tree(g)
  assert_eq(
    g.node("b").get_int_or("rank", -1),
    g.node("a").get_int_or("rank", -1) + 1,
  )
  inspect(tree.neighbors("a"), content="[\"b\"]")
}

///|
test "rank_feasible_tree shortens slack by pulling up" {
  let g = Graph::new()
  g.set_node("a", label=rank_ft_node_rank(0))
  g.set_node("b", label=rank_ft_node_rank(1))
  g.set_node("c", label=rank_ft_node_rank(2))
  g.set_node("d", label=rank_ft_node_rank(2))
  g.set_path(["a", "b", "c"], label=edge_minlen(1))
  g.set_edge("a", "d", label=edge_minlen(1))
  let tree = rank_feasible_tree(g)
  assert_eq(
    g.node("b").get_int_or("rank", -1),
    g.node("a").get_int_or("rank", -1) + 1,
  )
  assert_eq(
    g.node("c").get_int_or("rank", -1),
    g.node("b").get_int_or("rank", -1) + 1,
  )
  assert_eq(
    g.node("d").get_int_or("rank", -1),
    g.node("a").get_int_or("rank", -1) + 1,
  )
  let na = tree.neighbors("a")
  na.sort()
  inspect(na, content="[\"b\", \"d\"]")
  let nb = tree.neighbors("b")
  nb.sort()
  inspect(nb, content="[\"a\", \"c\"]")
  inspect(tree.neighbors("c"), content="[\"b\"]")
  inspect(tree.neighbors("d"), content="[\"a\"]")
}

///|
test "rank_feasible_tree shortens slack by pulling down" {
  let g = Graph::new()
  g.set_node("a", label=rank_ft_node_rank(2))
  g.set_node("b", label=rank_ft_node_rank(0))
  g.set_node("c", label=rank_ft_node_rank(2))
  g.set_edge("b", "a", label=edge_minlen(1))
  g.set_edge("b", "c", label=edge_minlen(1))
  let tree = rank_feasible_tree(g)
  assert_eq(
    g.node("a").get_int_or("rank", -1),
    g.node("b").get_int_or("rank", -1) + 1,
  )
  assert_eq(
    g.node("c").get_int_or("rank", -1),
    g.node("b").get_int_or("rank", -1) + 1,
  )
  let na = tree.neighbors("a")
  na.sort()
  inspect(na, content="[\"b\"]")
  let nb = tree.neighbors("b")
  nb.sort()
  inspect(nb, content="[\"a\", \"c\"]")
  let nc = tree.neighbors("c")
  nc.sort()
  inspect(nc, content="[\"b\"]")
}

///|
fn rank_ft_node_rank(rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs
}

///|
fn edge_minlen(minlen : Int) -> Value {
  let attrs = empty_attrs()
  attrs.set_int("minlen", minlen)
  attrs_value(attrs)
}

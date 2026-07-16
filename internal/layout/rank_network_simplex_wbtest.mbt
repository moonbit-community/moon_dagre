///|
// Upstream: dagre-reference/test/rank/network-simplex-test.js
test "network_simplex assigns rank to single node" {
  let g = Graph::new(multigraph=true)
  g.set_node("a", label=empty_attrs())
  rank_ns_run(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
}

///|
test "network_simplex assigns rank for 2-node graph" {
  let g = Graph::new(multigraph=true)
  g.set_node("a", label=empty_attrs())
  g.set_node("b", label=empty_attrs())
  g.set_edge("a", "b", label=rank_ns_edge())
  rank_ns_run(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
}

///|
test "network_simplex assigns ranks for diamond" {
  let g = Graph::new(multigraph=true)
  g.set_path(["a", "b", "d"], label=rank_ns_edge())
  g.set_path(["a", "c", "d"], label=rank_ns_edge())
  rank_ns_run(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
  assert_eq(g.node("c").get_int_or("rank", -1), 1)
  assert_eq(g.node("d").get_int_or("rank", -1), 2)
}

///|
test "network_simplex respects minlen" {
  let g = Graph::new(multigraph=true)
  g.set_path(["a", "b", "d"], label=rank_ns_edge())
  g.set_edge("a", "c", label=rank_ns_edge())
  g.set_edge("c", "d", label=rank_ns_edge(minlen=2))
  rank_ns_run(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 2)
  assert_eq(g.node("c").get_int_or("rank", -1), 1)
  assert_eq(g.node("d").get_int_or("rank", -1), 3)
}

///|
test "network_simplex ranks gansner graph" {
  let g = rank_ns_gansner_graph()
  rank_ns_run(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
  assert_eq(g.node("c").get_int_or("rank", -1), 2)
  assert_eq(g.node("d").get_int_or("rank", -1), 3)
  assert_eq(g.node("h").get_int_or("rank", -1), 4)
  assert_eq(g.node("e").get_int_or("rank", -1), 1)
  assert_eq(g.node("f").get_int_or("rank", -1), 1)
  assert_eq(g.node("g").get_int_or("rank", -1), 2)
}

///|
test "network_simplex handles multi-edges" {
  let g = Graph::new(multigraph=true)
  g.set_path(["a", "b", "c", "d"], label=rank_ns_edge())
  g.set_edge("a", "e", label=rank_ns_edge(weight=2, minlen=1))
  g.set_edge("e", "d", label=rank_ns_edge())
  g.set_edge("b", "c", label=rank_ns_edge(weight=1, minlen=2), name="multi")
  rank_ns_run(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
  assert_eq(g.node("c").get_int_or("rank", -1), 3)
  assert_eq(g.node("d").get_int_or("rank", -1), 4)
  assert_eq(g.node("e").get_int_or("rank", -1), 1)
}

///|
test "network_simplex leave_edge returns none if no negative cutvalue" {
  let tree = Graph::new(directed=false)
  tree.set_edge("a", "b", label=rank_ns_cutvalue(1))
  tree.set_edge("b", "c", label=rank_ns_cutvalue(1))
  assert_eq(rank_network_simplex_leave_edge(tree) is None, true)
}

///|
test "network_simplex leave_edge returns an edge for negative cutvalue" {
  let tree = Graph::new(directed=false)
  tree.set_edge("a", "b", label=rank_ns_cutvalue(1))
  tree.set_edge("b", "c", label=rank_ns_cutvalue(-1))
  let edge = rank_network_simplex_leave_edge(tree)
  assert_eq(edge is Some(_), true)
  if edge is Some(edge) {
    assert_eq(rank_ns_undirected_edge_key(edge), "b|c")
  }
}

///|
test "network_simplex enter_edge finds an edge from head to tail component" {
  let g = Graph::new(multigraph=true)
  g.set_node("a", label=rank_ns_rank(0))
  g.set_node("b", label=rank_ns_rank(2))
  g.set_node("c", label=rank_ns_rank(3))
  g.set_path(["a", "b", "c"], label=rank_ns_edge())
  g.set_edge("a", "c", label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_path(["b", "c", "a"], label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="c")
  let edge = rank_network_simplex_enter_edge(t, g, edge_obj("b", "c"))
  assert_eq(
    rank_ns_undirected_edge_key(edge),
    rank_ns_undirected_edge_key(edge_obj("a", "b")),
  )
}

///|
test "network_simplex enter_edge works when root is in tail component" {
  let g = Graph::new(multigraph=true)
  g.set_node("a", label=rank_ns_rank(0))
  g.set_node("b", label=rank_ns_rank(2))
  g.set_node("c", label=rank_ns_rank(3))
  g.set_path(["a", "b", "c"], label=rank_ns_edge())
  g.set_edge("a", "c", label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_path(["b", "c", "a"], label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="b")
  let edge = rank_network_simplex_enter_edge(t, g, edge_obj("b", "c"))
  assert_eq(
    rank_ns_undirected_edge_key(edge),
    rank_ns_undirected_edge_key(edge_obj("a", "b")),
  )
}

///|
test "network_simplex enter_edge finds edge with least slack" {
  let g = Graph::new(multigraph=true)
  g.set_node("a", label=rank_ns_rank(0))
  g.set_node("b", label=rank_ns_rank(1))
  g.set_node("c", label=rank_ns_rank(3))
  g.set_node("d", label=rank_ns_rank(4))
  g.set_edge("a", "d", label=rank_ns_edge())
  g.set_path(["a", "c", "d"], label=rank_ns_edge())
  g.set_edge("b", "c", label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_path(["c", "d", "a", "b"], label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="a")
  let edge = rank_network_simplex_enter_edge(t, g, edge_obj("c", "d"))
  assert_eq(
    rank_ns_undirected_edge_key(edge),
    rank_ns_undirected_edge_key(edge_obj("b", "c")),
  )
}

///|
test "network_simplex enter_edge gansner #1" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  rank_longest_path(g)
  rank_network_simplex_init_low_lim_values(t, root="a")
  let edge = rank_network_simplex_enter_edge(t, g, edge_obj("g", "h"))
  let key = rank_ns_undirected_edge_key(edge)
  assert_eq(key == "a|e" || key == "a|f", true)
}

///|
test "network_simplex enter_edge gansner #2" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  rank_longest_path(g)
  rank_network_simplex_init_low_lim_values(t, root="e")
  let edge = rank_network_simplex_enter_edge(t, g, edge_obj("g", "h"))
  let key = rank_ns_undirected_edge_key(edge)
  assert_eq(key == "a|e" || key == "a|f", true)
}

///|
test "network_simplex enter_edge gansner #3" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  rank_longest_path(g)
  rank_network_simplex_init_low_lim_values(t, root="a")
  let edge = rank_network_simplex_enter_edge(t, g, edge_obj("h", "g"))
  let key = rank_ns_undirected_edge_key(edge)
  assert_eq(key == "a|e" || key == "a|f", true)
}

///|
test "network_simplex enter_edge gansner #4" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  rank_longest_path(g)
  rank_network_simplex_init_low_lim_values(t, root="e")
  let edge = rank_network_simplex_enter_edge(t, g, edge_obj("h", "g"))
  let key = rank_ns_undirected_edge_key(edge)
  assert_eq(key == "a|e" || key == "a|f", true)
}

///|
test "network_simplex init_low_lim_values assigns low lim parent" {
  let g = Graph::new(directed=false)
  g.set_nodes(["a", "b", "c", "d", "e"], label=empty_attrs())
  g.set_path(
    ["a", "b", "a", "c", "d", "c", "e"],
    label=attrs_value(empty_attrs()),
  )
  rank_network_simplex_init_low_lim_values(g, root="a")
  let lims = g.nodes().map(v => g.node(v).get_int_or("lim", -1))
  lims.sort_by((a, b) => a - b)
  assert_eq(lims, [1, 2, 3, 4, 5])
  let a = g.node("a")
  assert_eq(a.get_int_or("low", -1), 1)
  assert_eq(a.get_int_or("lim", -1), 5)
  assert_eq(a.get_string("parent") is None, true)
  let b = g.node("b")
  assert_eq(b.get_string_or("parent", ""), "a")
  assert_eq(b.get_int_or("lim", -1) < a.get_int_or("lim", -1), true)
  let c = g.node("c")
  assert_eq(c.get_string_or("parent", ""), "a")
  assert_eq(c.get_int_or("lim", -1) < a.get_int_or("lim", -1), true)
  assert_eq(c.get_int_or("lim", -1) != b.get_int_or("lim", -1), true)
  let d = g.node("d")
  assert_eq(d.get_string_or("parent", ""), "c")
  assert_eq(d.get_int_or("lim", -1) < c.get_int_or("lim", -1), true)
  let e = g.node("e")
  assert_eq(e.get_string_or("parent", ""), "c")
  assert_eq(e.get_int_or("lim", -1) < c.get_int_or("lim", -1), true)
  assert_eq(e.get_int_or("lim", -1) != d.get_int_or("lim", -1), true)
}

///|
test "network_simplex exchange_edges updates cut values and low lim" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  rank_longest_path(g)
  rank_network_simplex_init_low_lim_values(t)
  rank_network_simplex_exchange_edges(
    t,
    g,
    edge_obj("g", "h"),
    edge_obj("a", "e"),
  )
  assert_eq(rank_ns_tree_cutvalue(t, "a", "b"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "b", "c"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "c", "d"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "d", "h"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "a", "e"), 1)
  assert_eq(rank_ns_tree_cutvalue(t, "e", "g"), 1)
  assert_eq(rank_ns_tree_cutvalue(t, "g", "f"), 0)
  let lims = t.nodes().map(v => t.node(v).get_int_or("lim", -1))
  lims.sort_by((a, b) => a - b)
  assert_eq(lims, [1, 2, 3, 4, 5, 6, 7, 8])
}

///|
test "network_simplex exchange_edges updates ranks" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  rank_longest_path(g)
  rank_network_simplex_init_low_lim_values(t)
  rank_network_simplex_exchange_edges(
    t,
    g,
    edge_obj("g", "h"),
    edge_obj("a", "e"),
  )
  normalize_ranks(g)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
  assert_eq(g.node("b").get_int_or("rank", -1), 1)
  assert_eq(g.node("c").get_int_or("rank", -1), 2)
  assert_eq(g.node("d").get_int_or("rank", -1), 3)
  assert_eq(g.node("e").get_int_or("rank", -1), 1)
  assert_eq(g.node("f").get_int_or("rank", -1), 1)
  assert_eq(g.node("g").get_int_or("rank", -1), 2)
  assert_eq(g.node("h").get_int_or("rank", -1), 4)
}

///|
test "network_simplex calc_cut_value 2-node c->p" {
  let g = Graph::new(multigraph=true)
  g.set_path(["c", "p"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_path(["p", "c"], label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 1)
}

///|
test "network_simplex calc_cut_value 2-node c<-p" {
  let g = Graph::new(multigraph=true)
  g.set_path(["p", "c"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_path(["p", "c"], label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 1)
}

///|
test "network_simplex calc_cut_value gc->c->p" {
  let g = Graph::new(multigraph=true)
  g.set_path(["gc", "c", "p"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("p", "c", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 3)
}

///|
test "network_simplex calc_cut_value gc->c<-p" {
  let g = Graph::new(multigraph=true)
  g.set_edge("p", "c", label=rank_ns_edge())
  g.set_edge("gc", "c", label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("p", "c", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), -1)
}

///|
test "network_simplex calc_cut_value gc<-c->p" {
  let g = Graph::new(multigraph=true)
  g.set_edge("c", "p", label=rank_ns_edge())
  g.set_edge("c", "gc", label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("p", "c", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), -1)
}

///|
test "network_simplex calc_cut_value gc<-c<-p" {
  let g = Graph::new(multigraph=true)
  g.set_path(["p", "c", "gc"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("p", "c", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 3)
}

///|
test "network_simplex calc_cut_value gc->c->p->o with o->c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("o", "c", label=rank_ns_edge(weight=7))
  g.set_path(["gc", "c", "p", "o"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_path(["c", "p", "o"], label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), -4)
}

///|
test "network_simplex calc_cut_value gc->c->p->o with o<-c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("c", "o", label=rank_ns_edge(weight=7))
  g.set_path(["gc", "c", "p", "o"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_path(["c", "p", "o"], label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 10)
}

///|
test "network_simplex calc_cut_value o->gc->c->p with o->c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("o", "c", label=rank_ns_edge(weight=7))
  g.set_path(["o", "gc", "c", "p"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("o", "gc", label=attrs_value(empty_attrs()))
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("c", "p", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), -4)
}

///|
test "network_simplex calc_cut_value o->gc->c->p with o<-c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("c", "o", label=rank_ns_edge(weight=7))
  g.set_path(["o", "gc", "c", "p"], label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("o", "gc", label=attrs_value(empty_attrs()))
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("c", "p", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 10)
}

///|
test "network_simplex calc_cut_value gc->c<-p->o with o->c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("gc", "c", label=rank_ns_edge())
  g.set_edge("p", "c", label=rank_ns_edge())
  g.set_edge("p", "o", label=rank_ns_edge())
  g.set_edge("o", "c", label=rank_ns_edge(weight=7))
  let t = Graph::new(directed=false)
  t.set_edge("o", "gc", label=attrs_value(empty_attrs()))
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("c", "p", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 6)
}

///|
test "network_simplex calc_cut_value gc->c<-p->o with o<-c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("gc", "c", label=rank_ns_edge())
  g.set_edge("p", "c", label=rank_ns_edge())
  g.set_edge("p", "o", label=rank_ns_edge())
  g.set_edge("c", "o", label=rank_ns_edge(weight=7))
  let t = Graph::new(directed=false)
  t.set_edge("o", "gc", label=attrs_value(empty_attrs()))
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("c", "p", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), -8)
}

///|
test "network_simplex calc_cut_value o->gc->c<-p with o->c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("o", "c", label=rank_ns_edge(weight=7))
  g.set_path(["o", "gc", "c"], label=rank_ns_edge())
  g.set_edge("p", "c", label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("o", "gc", label=attrs_value(empty_attrs()))
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("c", "p", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), 6)
}

///|
test "network_simplex calc_cut_value o->gc->c<-p with o<-c" {
  let g = Graph::new(multigraph=true)
  g.set_edge("c", "o", label=rank_ns_edge(weight=7))
  g.set_path(["o", "gc", "c"], label=rank_ns_edge())
  g.set_edge("p", "c", label=rank_ns_edge())
  let t = Graph::new(directed=false)
  t.set_edge("o", "gc", label=attrs_value(empty_attrs()))
  t.set_edge("gc", "c", label=rank_ns_cutvalue(3))
  t.set_edge("c", "p", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t, root="p")
  assert_eq(rank_network_simplex_calc_cut_value(t, g, "c"), -8)
}

///|
test "network_simplex init_cut_values works for gansner graph" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  rank_network_simplex_init_low_lim_values(t)
  rank_network_simplex_init_cut_values(t, g)
  assert_eq(rank_ns_tree_cutvalue(t, "a", "b"), 3)
  assert_eq(rank_ns_tree_cutvalue(t, "b", "c"), 3)
  assert_eq(rank_ns_tree_cutvalue(t, "c", "d"), 3)
  assert_eq(rank_ns_tree_cutvalue(t, "d", "h"), 3)
  assert_eq(rank_ns_tree_cutvalue(t, "g", "h"), -1)
  assert_eq(rank_ns_tree_cutvalue(t, "e", "g"), 0)
  assert_eq(rank_ns_tree_cutvalue(t, "f", "g"), 0)
}

///|
test "network_simplex init_cut_values works for updated gansner graph" {
  let g = rank_ns_gansner_graph()
  let t = rank_ns_gansner_tree()
  t.remove_edge("g", "h")
  t.set_edge("a", "e", label=attrs_value(empty_attrs()))
  rank_network_simplex_init_low_lim_values(t)
  rank_network_simplex_init_cut_values(t, g)
  assert_eq(rank_ns_tree_cutvalue(t, "a", "b"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "b", "c"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "c", "d"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "d", "h"), 2)
  assert_eq(rank_ns_tree_cutvalue(t, "a", "e"), 1)
  assert_eq(rank_ns_tree_cutvalue(t, "e", "g"), 1)
  assert_eq(rank_ns_tree_cutvalue(t, "f", "g"), 0)
}

///|
fn rank_ns_run(g : Graph) -> Unit {
  rank_network_simplex(g)
  normalize_ranks(g)
}

///|
fn rank_ns_edge(weight? : Int = 1, minlen? : Int = 1) -> Value {
  let attrs = empty_attrs()
  attrs.set_int("weight", weight)
  attrs.set_int("minlen", minlen)
  attrs_value(attrs)
}

///|
fn rank_ns_cutvalue(value : Int) -> Value {
  let attrs = empty_attrs()
  attrs.set_int("cutvalue", value)
  attrs_value(attrs)
}

///|
fn rank_ns_rank(rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("rank", rank)
  attrs
}

///|
fn rank_ns_tree_cutvalue(t : Graph, v : String, w : String) -> Int {
  if value_as_attrs(t.edge(v, w)) is Some(attrs) {
    attrs.get_int_or("cutvalue", 0)
  } else {
    0
  }
}

///|
fn rank_ns_undirected_edge_key(e : EdgeObj) -> String {
  if e.v < e.w {
    "\{e.v}|\{e.w}"
  } else {
    "\{e.w}|\{e.v}"
  }
}

///|
fn rank_ns_gansner_graph() -> Graph {
  let g = Graph::new(multigraph=true)
  g.set_path(["a", "b", "c", "d", "h"], label=rank_ns_edge())
  g.set_path(["a", "e", "g", "h"], label=rank_ns_edge())
  g.set_path(["a", "f", "g"], label=rank_ns_edge())
  g
}

///|
fn rank_ns_gansner_tree() -> Graph {
  let t = Graph::new(directed=false)
  t.set_path(
    ["a", "b", "c", "d", "h", "g", "e"],
    label=attrs_value(empty_attrs()),
  )
  t.set_edge("g", "f", label=attrs_value(empty_attrs()))
  t
}

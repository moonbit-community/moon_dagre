///|
// Upstream: dagre-reference/test/parent-dummy-chains-test.js
test "parent_dummy_chains does not set parent if tail and head have no parent" {
  let g = pdc_graph()
  g.set_node("a")
  g.set_node("b")
  g.set_node("d1", label=pdc_dummy(edge_v="a", edge_w="b"))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), None)
}

///|
test "parent_dummy_chains uses tail parent for first node if not root" {
  let g = pdc_graph()
  g.set_parent("a", parent="sg1")
  g.set_node("sg1", label=pdc_range(0, 2))
  g.set_node("d1", label=pdc_dummy(rank=2, edge_v="a", edge_w="b"))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), Some("sg1"))
}

///|
test "parent_dummy_chains uses head parent for first node if tail parent is root" {
  let g = pdc_graph()
  g.set_parent("b", parent="sg1")
  g.set_node("sg1", label=pdc_range(1, 3))
  g.set_node("d1", label=pdc_dummy(rank=1, edge_v="a", edge_w="b"))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), Some("sg1"))
}

///|
test "parent_dummy_chains handles long chain starting in a subgraph" {
  let g = pdc_graph()
  g.set_parent("a", parent="sg1")
  g.set_node("sg1", label=pdc_range(0, 2))
  g.set_node("d1", label=pdc_dummy(rank=2, edge_v="a", edge_w="b"))
  g.set_node("d2", label=pdc_dummy(rank=3))
  g.set_node("d3", label=pdc_dummy(rank=4))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "d2", "d3", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), Some("sg1"))
  assert_eq(g.parent("d2"), None)
  assert_eq(g.parent("d3"), None)
}

///|
test "parent_dummy_chains handles long chain ending in a subgraph" {
  let g = pdc_graph()
  g.set_parent("b", parent="sg1")
  g.set_node("sg1", label=pdc_range(3, 5))
  g.set_node("d1", label=pdc_dummy(rank=1, edge_v="a", edge_w="b"))
  g.set_node("d2", label=pdc_dummy(rank=2))
  g.set_node("d3", label=pdc_dummy(rank=3))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "d2", "d3", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), None)
  assert_eq(g.parent("d2"), None)
  assert_eq(g.parent("d3"), Some("sg1"))
}

///|
test "parent_dummy_chains handles nested subgraphs" {
  let g = pdc_graph()
  g.set_parent("a", parent="sg2")
  g.set_parent("sg2", parent="sg1")
  g.set_node("sg1", label=pdc_range(0, 4))
  g.set_node("sg2", label=pdc_range(1, 3))
  g.set_parent("b", parent="sg4")
  g.set_parent("sg4", parent="sg3")
  g.set_node("sg3", label=pdc_range(6, 10))
  g.set_node("sg4", label=pdc_range(7, 9))
  g.set_node("d1", label=pdc_dummy(rank=3, edge_v="a", edge_w="b"))
  g.set_node("d2", label=pdc_dummy(rank=4))
  g.set_node("d3", label=pdc_dummy(rank=5))
  g.set_node("d4", label=pdc_dummy(rank=6))
  g.set_node("d5", label=pdc_dummy(rank=7))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "d2", "d3", "d4", "d5", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), Some("sg2"))
  assert_eq(g.parent("d2"), Some("sg1"))
  assert_eq(g.parent("d3"), None)
  assert_eq(g.parent("d4"), Some("sg3"))
  assert_eq(g.parent("d5"), Some("sg4"))
}

///|
test "parent_dummy_chains handles overlapping rank ranges" {
  let g = pdc_graph()
  g.set_parent("a", parent="sg1")
  g.set_node("sg1", label=pdc_range(0, 3))
  g.set_parent("b", parent="sg2")
  g.set_node("sg2", label=pdc_range(2, 6))
  g.set_node("d1", label=pdc_dummy(rank=2, edge_v="a", edge_w="b"))
  g.set_node("d2", label=pdc_dummy(rank=3))
  g.set_node("d3", label=pdc_dummy(rank=4))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "d2", "d3", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), Some("sg1"))
  assert_eq(g.parent("d2"), Some("sg1"))
  assert_eq(g.parent("d3"), Some("sg2"))
}

///|
test "parent_dummy_chains handles non-root LCA #1" {
  let g = pdc_graph()
  g.set_parent("a", parent="sg1")
  g.set_parent("sg2", parent="sg1")
  g.set_node("sg1", label=pdc_range(0, 6))
  g.set_parent("b", parent="sg2")
  g.set_node("sg2", label=pdc_range(3, 5))
  g.set_node("d1", label=pdc_dummy(rank=2, edge_v="a", edge_w="b"))
  g.set_node("d2", label=pdc_dummy(rank=3))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "d2", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), Some("sg1"))
  assert_eq(g.parent("d2"), Some("sg2"))
}

///|
test "parent_dummy_chains handles non-root LCA #2" {
  let g = pdc_graph()
  g.set_parent("a", parent="sg2")
  g.set_parent("sg2", parent="sg1")
  g.set_node("sg1", label=pdc_range(0, 6))
  g.set_parent("b", parent="sg1")
  g.set_node("sg2", label=pdc_range(1, 3))
  g.set_node("d1", label=pdc_dummy(rank=3, edge_v="a", edge_w="b"))
  g.set_node("d2", label=pdc_dummy(rank=4))
  g.graph().set_strings("dummyChains", ["d1"])
  g.set_path(["a", "d1", "d2", "b"])
  parent_dummy_chains(g)
  assert_eq(g.parent("d1"), Some("sg2"))
  assert_eq(g.parent("d2"), Some("sg1"))
}

///|
fn pdc_graph() -> Graph {
  let g = Graph::new(compound=true)
  g.set_graph(empty_attrs())
  g
}

///|
fn pdc_range(min_rank : Int, max_rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("minRank", min_rank)
  attrs.set_int("maxRank", max_rank)
  attrs
}

///|
fn pdc_dummy(rank? : Int, edge_v? : String, edge_w? : String) -> Attrs {
  let attrs = empty_attrs()
  if rank is Some(rank) {
    attrs.set_int("rank", rank)
  }
  if edge_v is Some(edge_v) && edge_w is Some(edge_w) {
    attrs.set_edge("edgeObj", edge_obj(edge_v, edge_w))
  }
  attrs
}

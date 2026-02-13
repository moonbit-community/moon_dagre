///|
// Upstream: dagre-reference/test/nesting-graph-test.js
test "nesting_graph_run connects a disconnected graph" {
  let g = nesting_graph_fixture()
  g.set_node("a")
  g.set_node("b")
  assert_eq(components(g).length(), 2)
  nesting_graph_run(g)
  assert_eq(components(g).length(), 1)
  assert_eq(g.has_node("a"), true)
  assert_eq(g.has_node("b"), true)
}

///|
test "nesting_graph_run adds border nodes to top and bottom of a subgraph" {
  let g = nesting_graph_fixture()
  g.set_parent("a", parent="sg1")
  nesting_graph_run(g)
  let sg1 = g.node("sg1")
  let border_top = sg1.get_string("borderTop")
  let border_bottom = sg1.get_string("borderBottom")
  assert_eq(border_top is Some(_), true)
  assert_eq(border_bottom is Some(_), true)
  if border_top is Some(border_top) && border_bottom is Some(border_bottom) {
    assert_eq(g.parent(border_top), Some("sg1"))
    assert_eq(g.parent(border_bottom), Some("sg1"))
    assert_eq(g.out_edges(border_top, w="a").length(), 1)
    assert_eq(
      nesting_edge_attrs(g, border_top, "a").get_int_or("minlen", -1),
      1,
    )
    assert_eq(g.out_edges("a", w=border_bottom).length(), 1)
    assert_eq(
      nesting_edge_attrs(g, "a", border_bottom).get_int_or("minlen", -1),
      1,
    )
    nesting_assert_border_dummy(g, border_top)
    nesting_assert_border_dummy(g, border_bottom)
  }
}

///|
test "nesting_graph_run adds edges between borders of nested subgraphs" {
  let g = nesting_graph_fixture()
  g.set_parent("sg2", parent="sg1")
  g.set_parent("a", parent="sg2")
  nesting_graph_run(g)
  let sg1_top = g.node("sg1").get_string("borderTop")
  let sg1_bottom = g.node("sg1").get_string("borderBottom")
  let sg2_top = g.node("sg2").get_string("borderTop")
  let sg2_bottom = g.node("sg2").get_string("borderBottom")
  assert_eq(sg1_top is Some(_), true)
  assert_eq(sg1_bottom is Some(_), true)
  assert_eq(sg2_top is Some(_), true)
  assert_eq(sg2_bottom is Some(_), true)
  if sg1_top is Some(sg1_top) && sg2_top is Some(sg2_top) {
    assert_eq(g.out_edges(sg1_top, w=sg2_top).length(), 1)
    assert_eq(
      nesting_edge_attrs(g, sg1_top, sg2_top).get_int_or("minlen", -1),
      1,
    )
  }
  if sg2_bottom is Some(sg2_bottom) && sg1_bottom is Some(sg1_bottom) {
    assert_eq(g.out_edges(sg2_bottom, w=sg1_bottom).length(), 1)
    assert_eq(
      nesting_edge_attrs(g, sg2_bottom, sg1_bottom).get_int_or("minlen", -1),
      1,
    )
  }
}

///|
test "nesting_graph_run adds sufficient weight to border-to-node edges" {
  let g = nesting_graph_fixture()
  g.set_parent("x", parent="sg")
  g.set_edge("a", "x", label=nesting_edge_label(weight=100))
  g.set_edge("x", "b", label=nesting_edge_label(weight=200))
  nesting_graph_run(g)
  let top = g.node("sg").get_string("borderTop")
  let bottom = g.node("sg").get_string("borderBottom")
  assert_eq(top is Some(_), true)
  assert_eq(bottom is Some(_), true)
  if top is Some(top) && bottom is Some(bottom) {
    assert_eq(
      nesting_edge_attrs(g, top, "x").get_float_or("weight", -1.0) > 300.0,
      true,
    )
    assert_eq(
      nesting_edge_attrs(g, "x", bottom).get_float_or("weight", -1.0) > 300.0,
      true,
    )
  }
}

///|
test "nesting_graph_run adds an edge from root to tops of top-level subgraphs" {
  let g = nesting_graph_fixture()
  g.set_parent("a", parent="sg1")
  nesting_graph_run(g)
  let root = g.graph().get_string("nestingRoot")
  let top = g.node("sg1").get_string("borderTop")
  assert_eq(root is Some(_), true)
  assert_eq(top is Some(_), true)
  if root is Some(root) && top is Some(top) {
    assert_eq(g.out_edges(root, w=top).length(), 1)
    assert_eq(g.has_edge(root, top), true)
  }
}

///|
test "nesting_graph_run adds edge root->node with correct minlen #1" {
  let g = nesting_graph_fixture()
  g.set_node("a")
  nesting_graph_run(g)
  let root = g.graph().get_string("nestingRoot")
  assert_eq(root is Some(_), true)
  if root is Some(root) {
    assert_eq(g.out_edges(root, w="a").length(), 1)
    let edge = nesting_edge_attrs(g, root, "a")
    assert_eq(edge.get_int_or("weight", -1), 0)
    assert_eq(edge.get_int_or("minlen", -1), 1)
  }
}

///|
test "nesting_graph_run adds edge root->node with correct minlen #2" {
  let g = nesting_graph_fixture()
  g.set_parent("a", parent="sg1")
  nesting_graph_run(g)
  let root = g.graph().get_string("nestingRoot")
  assert_eq(root is Some(_), true)
  if root is Some(root) {
    assert_eq(g.out_edges(root, w="a").length(), 1)
    let edge = nesting_edge_attrs(g, root, "a")
    assert_eq(edge.get_int_or("weight", -1), 0)
    assert_eq(edge.get_int_or("minlen", -1), 3)
  }
}

///|
test "nesting_graph_run adds edge root->node with correct minlen #3" {
  let g = nesting_graph_fixture()
  g.set_parent("sg2", parent="sg1")
  g.set_parent("a", parent="sg2")
  nesting_graph_run(g)
  let root = g.graph().get_string("nestingRoot")
  assert_eq(root is Some(_), true)
  if root is Some(root) {
    assert_eq(g.out_edges(root, w="a").length(), 1)
    let edge = nesting_edge_attrs(g, root, "a")
    assert_eq(edge.get_int_or("weight", -1), 0)
    assert_eq(edge.get_int_or("minlen", -1), 5)
  }
}

///|
test "nesting_graph_run does not add edge from root to itself" {
  let g = nesting_graph_fixture()
  g.set_node("a")
  nesting_graph_run(g)
  let root = g.graph().get_string("nestingRoot")
  assert_eq(root is Some(_), true)
  if root is Some(root) {
    assert_eq(g.out_edges(root, w=root).is_empty(), true)
  }
}

///|
test "nesting_graph_run expands inter-node edges #1" {
  let g = nesting_graph_fixture()
  g.set_edge("a", "b", label=nesting_edge_label(minlen=1))
  nesting_graph_run(g)
  assert_eq(nesting_edge_attrs(g, "a", "b").get_int_or("minlen", -1), 1)
}

///|
test "nesting_graph_run expands inter-node edges #2" {
  let g = nesting_graph_fixture()
  g.set_parent("a", parent="sg1")
  g.set_edge("a", "b", label=nesting_edge_label(minlen=1))
  nesting_graph_run(g)
  assert_eq(nesting_edge_attrs(g, "a", "b").get_int_or("minlen", -1), 3)
}

///|
test "nesting_graph_run expands inter-node edges #3" {
  let g = nesting_graph_fixture()
  g.set_parent("sg2", parent="sg1")
  g.set_parent("a", parent="sg2")
  g.set_edge("a", "b", label=nesting_edge_label(minlen=1))
  nesting_graph_run(g)
  assert_eq(nesting_edge_attrs(g, "a", "b").get_int_or("minlen", -1), 5)
}

///|
test "nesting_graph_run sets minlen correctly for nested border-to-children edges" {
  let g = nesting_graph_fixture()
  g.set_parent("a", parent="sg1")
  g.set_parent("sg2", parent="sg1")
  g.set_parent("b", parent="sg2")
  nesting_graph_run(g)
  let root = g.graph().get_string("nestingRoot")
  let sg1_top = g.node("sg1").get_string("borderTop")
  let sg1_bottom = g.node("sg1").get_string("borderBottom")
  let sg2_top = g.node("sg2").get_string("borderTop")
  let sg2_bottom = g.node("sg2").get_string("borderBottom")
  assert_eq(root is Some(_), true)
  assert_eq(sg1_top is Some(_), true)
  assert_eq(sg1_bottom is Some(_), true)
  assert_eq(sg2_top is Some(_), true)
  assert_eq(sg2_bottom is Some(_), true)
  if root is Some(root) &&
    sg1_top is Some(sg1_top) &&
    sg1_bottom is Some(sg1_bottom) &&
    sg2_top is Some(sg2_top) &&
    sg2_bottom is Some(sg2_bottom) {
    assert_eq(nesting_edge_attrs(g, root, sg1_top).get_int_or("minlen", -1), 3)
    assert_eq(
      nesting_edge_attrs(g, sg1_top, sg2_top).get_int_or("minlen", -1),
      1,
    )
    assert_eq(nesting_edge_attrs(g, sg1_top, "a").get_int_or("minlen", -1), 2)
    assert_eq(
      nesting_edge_attrs(g, "a", sg1_bottom).get_int_or("minlen", -1),
      2,
    )
    assert_eq(nesting_edge_attrs(g, sg2_top, "b").get_int_or("minlen", -1), 1)
    assert_eq(
      nesting_edge_attrs(g, "b", sg2_bottom).get_int_or("minlen", -1),
      1,
    )
    assert_eq(
      nesting_edge_attrs(g, sg2_bottom, sg1_bottom).get_int_or("minlen", -1),
      1,
    )
  }
}

///|
test "nesting_graph_cleanup removes nesting graph edges" {
  let g = nesting_graph_fixture()
  g.set_parent("a", parent="sg1")
  g.set_edge("a", "b", label=nesting_edge_label(minlen=1))
  nesting_graph_run(g)
  nesting_graph_cleanup(g)
  inspect(g.successors("a"), content="[\"b\"]")
}

///|
test "nesting_graph_cleanup removes root node" {
  let g = nesting_graph_fixture()
  g.set_parent("a", parent="sg1")
  nesting_graph_run(g)
  nesting_graph_cleanup(g)
  assert_eq(g.node_count(), 4)
}

///|
fn nesting_graph_fixture() -> Graph {
  let g = Graph::new(compound=true)
  g.set_graph(empty_attrs())
  g
}

///|
fn nesting_edge_label(
  minlen? : Int = 1,
  weight? : Int = 1,
  nesting_edge? : Bool = false,
) -> Value {
  let attrs = empty_attrs()
  attrs.set_int("minlen", minlen)
  attrs.set_int("weight", weight)
  if nesting_edge {
    attrs.set_bool("nestingEdge", true)
  }
  attrs_value(attrs)
}

///|
fn nesting_edge_attrs(g : Graph, v : String, w : String) -> Attrs {
  if value_as_attrs(g.edge(v, w)) is Some(attrs) {
    attrs
  } else {
    empty_attrs()
  }
}

///|
fn nesting_assert_border_dummy(g : Graph, v : String) -> Unit raise {
  let node = g.node(v)
  assert_eq(node.get_string_or("dummy", ""), "border")
  assert_eq(node.get_float_or("width", -1.0), 0.0)
  assert_eq(node.get_float_or("height", -1.0), 0.0)
}

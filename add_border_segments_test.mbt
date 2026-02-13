///|
// Upstream: dagre-reference/test/add-border-segments-test.js
test "add_border_segments does not add border nodes for non-compound graph" {
  let g = Graph::new()
  let node = empty_attrs()
  node.set_int("rank", 0)
  g.set_node("a", label=node)
  add_border_segments(g)
  assert_eq(g.node_count(), 1)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
}

///|
test "add_border_segments does not add border nodes for graph with no clusters" {
  let g = add_bs_graph()
  let node = empty_attrs()
  node.set_int("rank", 0)
  g.set_node("a", label=node)
  add_border_segments(g)
  assert_eq(g.node_count(), 1)
  assert_eq(g.node("a").get_int_or("rank", -1), 0)
}

///|
test "add_border_segments adds border for single-rank subgraph" {
  let g = add_bs_graph()
  g.set_node("sg", label=add_bs_range(1, 1))
  add_border_segments(g)
  let sg = g.node("sg")
  let bl = add_bs_border_at(sg, "borderLeft", 1)
  let br = add_bs_border_at(sg, "borderRight", 1)
  assert_eq(bl is Some(_), true)
  assert_eq(br is Some(_), true)
  if bl is Some(bl) {
    add_bs_assert_border_node(g, bl, "borderLeft", 1, "sg")
  }
  if br is Some(br) {
    add_bs_assert_border_node(g, br, "borderRight", 1, "sg")
  }
}

///|
test "add_border_segments adds border for multi-rank subgraph" {
  let g = add_bs_graph()
  g.set_node("sg", label=add_bs_range(1, 2))
  add_border_segments(g)
  let sg = g.node("sg")
  let bl1 = add_bs_border_at(sg, "borderLeft", 1)
  let br1 = add_bs_border_at(sg, "borderRight", 1)
  let bl2 = add_bs_border_at(sg, "borderLeft", 2)
  let br2 = add_bs_border_at(sg, "borderRight", 2)
  assert_eq(bl1 is Some(_), true)
  assert_eq(br1 is Some(_), true)
  assert_eq(bl2 is Some(_), true)
  assert_eq(br2 is Some(_), true)
  if bl1 is Some(bl1) {
    add_bs_assert_border_node(g, bl1, "borderLeft", 1, "sg")
    if bl2 is Some(bl2) {
      assert_eq(g.has_edge(bl1, bl2), true)
    }
  }
  if br1 is Some(br1) {
    add_bs_assert_border_node(g, br1, "borderRight", 1, "sg")
    if br2 is Some(br2) {
      assert_eq(g.has_edge(br1, br2), true)
    }
  }
  if bl2 is Some(bl2) {
    add_bs_assert_border_node(g, bl2, "borderLeft", 2, "sg")
  }
  if br2 is Some(br2) {
    add_bs_assert_border_node(g, br2, "borderRight", 2, "sg")
  }
}

///|
test "add_border_segments adds borders for nested subgraphs" {
  let g = add_bs_graph()
  g.set_node("sg1", label=add_bs_range(1, 1))
  g.set_node("sg2", label=add_bs_range(1, 1))
  g.set_parent("sg2", parent="sg1")
  add_border_segments(g)
  let sg1 = g.node("sg1")
  let sg2 = g.node("sg2")
  let sg1_bl = add_bs_border_at(sg1, "borderLeft", 1)
  let sg1_br = add_bs_border_at(sg1, "borderRight", 1)
  let sg2_bl = add_bs_border_at(sg2, "borderLeft", 1)
  let sg2_br = add_bs_border_at(sg2, "borderRight", 1)
  assert_eq(sg1_bl is Some(_), true)
  assert_eq(sg1_br is Some(_), true)
  assert_eq(sg2_bl is Some(_), true)
  assert_eq(sg2_br is Some(_), true)
  if sg1_bl is Some(v) {
    add_bs_assert_border_node(g, v, "borderLeft", 1, "sg1")
  }
  if sg1_br is Some(v) {
    add_bs_assert_border_node(g, v, "borderRight", 1, "sg1")
  }
  if sg2_bl is Some(v) {
    add_bs_assert_border_node(g, v, "borderLeft", 1, "sg2")
  }
  if sg2_br is Some(v) {
    add_bs_assert_border_node(g, v, "borderRight", 1, "sg2")
  }
}

///|
fn add_bs_graph() -> Graph {
  Graph::new(compound=true)
}

///|
fn add_bs_range(min_rank : Int, max_rank : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_int("minRank", min_rank)
  attrs.set_int("maxRank", max_rank)
  attrs
}

///|
fn add_bs_border_at(node : Attrs, prop : String, rank : Int) -> String? {
  if node.get_strings(prop) is Some(border_nodes) {
    if rank >= 0 && rank < border_nodes.length() {
      let value = border_nodes[rank]
      if value == "" {
        None
      } else {
        Some(value)
      }
    } else {
      None
    }
  } else {
    None
  }
}

///|
fn add_bs_assert_border_node(
  g : Graph,
  v : String,
  border_type : String,
  rank : Int,
  parent : String,
) -> Unit raise {
  let node = g.node(v)
  assert_eq(node.get_string_or("dummy", ""), "border")
  assert_eq(node.get_string_or("borderType", ""), border_type)
  assert_eq(node.get_int_or("rank", -1), rank)
  assert_eq(node.get_float_or("width", -1.0), 0.0)
  assert_eq(node.get_float_or("height", -1.0), 0.0)
  assert_eq(g.parent(v), Some(parent))
}

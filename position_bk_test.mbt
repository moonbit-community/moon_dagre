///|
// Upstream: dagre-reference/test/position/bk-test.js
test "position_bk findType1 no conflict edges" {
  let g = position_bk_crossing_fixture()
  g.remove_edge("a", "d")
  g.remove_edge("b", "c")
  g.set_edge("a", "c", label=attrs_value(empty_attrs()))
  g.set_edge("b", "d", label=attrs_value(empty_attrs()))
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "c"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "d"), false)
}

///|
test "position_bk findType1 does not mark type0 conflicts" {
  let g = position_bk_crossing_fixture()
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 marks type1 conflicts when one endpoint non-dummy" {
  let g = position_bk_crossing_fixture()
  g.node("b").set_bool("dummy", true)
  g.node("c").set_bool("dummy", true)
  g.node("d").set_bool("dummy", true)
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), true)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 does not mark type0 conflicts (a is dummy)" {
  let g = position_bk_crossing_fixture()
  g.node("a").set_bool("dummy", true)
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 does not mark type0 conflicts (b is dummy)" {
  let g = position_bk_crossing_fixture()
  g.node("b").set_bool("dummy", true)
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 does not mark type0 conflicts (c is dummy)" {
  let g = position_bk_crossing_fixture()
  g.node("c").set_bool("dummy", true)
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 does not mark type0 conflicts (d is dummy)" {
  let g = position_bk_crossing_fixture()
  g.node("d").set_bool("dummy", true)
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 marks type1 conflicts (a is non-dummy)" {
  let g = position_bk_crossing_fixture()
  for v in ["b", "c", "d"] {
    g.node(v).set_bool("dummy", true)
  }
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), true)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 marks type1 conflicts (b is non-dummy)" {
  let g = position_bk_crossing_fixture()
  for v in ["a", "c", "d"] {
    g.node(v).set_bool("dummy", true)
  }
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), true)
}

///|
test "position_bk findType1 marks type1 conflicts (c is non-dummy)" {
  let g = position_bk_crossing_fixture()
  for v in ["a", "b", "d"] {
    g.node(v).set_bool("dummy", true)
  }
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), true)
}

///|
test "position_bk findType1 marks type1 conflicts (d is non-dummy)" {
  let g = position_bk_crossing_fixture()
  for v in ["a", "b", "c"] {
    g.node(v).set_bool("dummy", true)
  }
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), true)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType1 all dummies not marked" {
  let g = position_bk_crossing_fixture()
  for v in ["a", "b", "c", "d"] {
    g.node(v).set_bool("dummy", true)
  }
  let conflicts = position_bk_find_type1_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType2 marks favoring border segments #1" {
  let g = position_bk_crossing_fixture()
  g.node("a").set_bool("dummy", true)
  g.node("d").set_bool("dummy", true)
  g.node("b").set_string("dummy", "border")
  g.node("c").set_string("dummy", "border")
  let conflicts = position_bk_find_type2_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), true)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), false)
}

///|
test "position_bk findType2 marks favoring border segments #2" {
  let g = position_bk_crossing_fixture()
  g.node("b").set_bool("dummy", true)
  g.node("c").set_bool("dummy", true)
  g.node("a").set_string("dummy", "border")
  g.node("d").set_string("dummy", "border")
  let conflicts = position_bk_find_type2_conflicts(g, build_layer_matrix(g))
  assert_eq(position_bk_has_conflict(conflicts, "a", "d"), false)
  assert_eq(position_bk_has_conflict(conflicts, "b", "c"), true)
}

///|
test "position_bk hasConflict works with orientation and multiple" {
  let conflicts : Map[String, Set[String]] = Map::new()
  position_bk_add_conflict(conflicts, "b", "a")
  position_bk_add_conflict(conflicts, "a", "c")
  assert_eq(position_bk_has_conflict(conflicts, "a", "b"), true)
  assert_eq(position_bk_has_conflict(conflicts, "b", "a"), true)
  assert_eq(position_bk_has_conflict(conflicts, "a", "c"), true)
}

///|
test "position_bk verticalAlignment aligns node with itself when no adjacencies" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 1, 0))
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    Map::new(),
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("a", ""), "a")
  assert_eq(result.root.get_or_default("b", ""), "b")
  assert_eq(result.align.get_or_default("a", ""), "a")
  assert_eq(result.align.get_or_default("b", ""), "b")
}

///|
test "position_bk verticalAlignment aligns with sole adjacency" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 1, 0))
  g.set_edge("a", "b", label=attrs_value(empty_attrs()))
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    Map::new(),
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("a", ""), "a")
  assert_eq(result.root.get_or_default("b", ""), "a")
  assert_eq(result.align.get_or_default("a", ""), "b")
  assert_eq(result.align.get_or_default("b", ""), "a")
}

///|
test "position_bk verticalAlignment uses left median when possible" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 0, 1))
  g.set_node("c", label=position_bk_node(50.0, 1, 0))
  g.set_edge("a", "c", label=attrs_value(empty_attrs()))
  g.set_edge("b", "c", label=attrs_value(empty_attrs()))
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    Map::new(),
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("c", ""), "a")
  assert_eq(result.align.get_or_default("a", ""), "c")
}

///|
test "position_bk verticalAlignment sorts candidates by position" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("b", label=position_bk_node(50.0, 0, 1))
  g.set_node("c", label=position_bk_node(50.0, 1, 0))
  g.set_node("z", label=position_bk_node(50.0, 0, 0))
  g.set_edge("z", "c", label=attrs_value(empty_attrs()))
  g.set_edge("b", "c", label=attrs_value(empty_attrs()))
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    Map::new(),
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("z", ""), "z")
  assert_eq(result.root.get_or_default("b", ""), "b")
  assert_eq(result.root.get_or_default("c", ""), "z")
  assert_eq(result.align.get_or_default("z", ""), "c")
  assert_eq(result.align.get_or_default("b", ""), "b")
  assert_eq(result.align.get_or_default("c", ""), "z")
}

///|
test "position_bk verticalAlignment uses right median when left blocked" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 0, 1))
  g.set_node("c", label=position_bk_node(50.0, 1, 0))
  g.set_edge("a", "c", label=attrs_value(empty_attrs()))
  g.set_edge("b", "c", label=attrs_value(empty_attrs()))
  let conflicts : Map[String, Set[String]] = Map::new()
  position_bk_add_conflict(conflicts, "a", "c")
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    conflicts,
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("c", ""), "b")
  assert_eq(result.align.get_or_default("b", ""), "c")
}

///|
test "position_bk verticalAlignment aligns with neither median if both unavailable" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 0, 1))
  g.set_node("c", label=position_bk_node(50.0, 1, 0))
  g.set_node("d", label=position_bk_node(50.0, 1, 1))
  g.set_edge("a", "d", label=attrs_value(empty_attrs()))
  g.set_edge("b", "c", label=attrs_value(empty_attrs()))
  g.set_edge("b", "d", label=attrs_value(empty_attrs()))
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    Map::new(),
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("a", ""), "a")
  assert_eq(result.root.get_or_default("b", ""), "b")
  assert_eq(result.root.get_or_default("c", ""), "b")
  assert_eq(result.root.get_or_default("d", ""), "d")
  assert_eq(result.align.get_or_default("a", ""), "a")
  assert_eq(result.align.get_or_default("b", ""), "c")
  assert_eq(result.align.get_or_default("c", ""), "b")
  assert_eq(result.align.get_or_default("d", ""), "d")
}

///|
test "position_bk verticalAlignment aligns odd adjacencies to single median" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 0, 1))
  g.set_node("c", label=position_bk_node(50.0, 0, 2))
  g.set_node("d", label=position_bk_node(50.0, 1, 0))
  g.set_edge("a", "d", label=attrs_value(empty_attrs()))
  g.set_edge("b", "d", label=attrs_value(empty_attrs()))
  g.set_edge("c", "d", label=attrs_value(empty_attrs()))
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    Map::new(),
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("d", ""), "b")
  assert_eq(result.align.get_or_default("b", ""), "d")
}

///|
test "position_bk verticalAlignment aligns blocks across multiple layers" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 1, 0))
  g.set_node("c", label=position_bk_node(50.0, 1, 1))
  g.set_node("d", label=position_bk_node(50.0, 2, 0))
  g.set_path(["a", "b", "d"], label=attrs_value(empty_attrs()))
  g.set_path(["a", "c", "d"], label=attrs_value(empty_attrs()))
  let result = position_bk_vertical_alignment(
    g,
    build_layer_matrix(g),
    Map::new(),
    v => g.predecessors(v),
  )
  assert_eq(result.root.get_or_default("a", ""), "a")
  assert_eq(result.root.get_or_default("b", ""), "a")
  assert_eq(result.root.get_or_default("c", ""), "c")
  assert_eq(result.root.get_or_default("d", ""), "a")
  assert_eq(result.align.get_or_default("a", ""), "b")
  assert_eq(result.align.get_or_default("b", ""), "d")
  assert_eq(result.align.get_or_default("c", ""), "c")
  assert_eq(result.align.get_or_default("d", ""), "a")
}

///|
test "position_bk horizontalCompaction single node at origin" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(100.0, 0, 0))
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
}

///|
test "position_bk horizontalCompaction separates nodes by nodesep" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 100.0)
  g.set_graph(graph)
  g.set_node("a", label=position_bk_node(100.0, 0, 0))
  g.set_node("b", label=position_bk_node(200.0, 0, 1))
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  align.set("b", "b")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  assert_eq(xs.get_or_default("b", -1.0), 100.0 / 2.0 + 100.0 + 200.0 / 2.0)
}

///|
test "position_bk horizontalCompaction separates dummy nodes by edgesep" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("edgesep", 20.0)
  g.set_graph(graph)
  let a = position_bk_node(100.0, 0, 0)
  a.set_bool("dummy", true)
  let b = position_bk_node(200.0, 0, 1)
  b.set_bool("dummy", true)
  g.set_node("a", label=a)
  g.set_node("b", label=b)
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  align.set("b", "b")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("b", -1.0), 100.0 / 2.0 + 20.0 + 200.0 / 2.0)
}

///|
test "position_bk horizontalCompaction aligns centers in same block" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(100.0, 0, 0))
  g.set_node("b", label=position_bk_node(200.0, 1, 0))
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "a")
  let align : Map[String, String] = Map::new()
  align.set("a", "b")
  align.set("b", "a")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  assert_eq(xs.get_or_default("b", -1.0), 0.0)
}

///|
test "position_bk horizontalCompaction separates blocks with appropriate sep" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 75.0)
  g.set_graph(graph)
  g.set_node("a", label=position_bk_node(100.0, 0, 0))
  g.set_node("b", label=position_bk_node(200.0, 1, 1))
  g.set_node("c", label=position_bk_node(50.0, 1, 0))
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "a")
  root.set("c", "c")
  let align : Map[String, String] = Map::new()
  align.set("a", "b")
  align.set("b", "a")
  align.set("c", "c")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 50.0 / 2.0 + 75.0 + 200.0 / 2.0)
  assert_eq(xs.get_or_default("b", -1.0), 50.0 / 2.0 + 75.0 + 200.0 / 2.0)
  assert_eq(xs.get_or_default("c", -1.0), 0.0)
}

///|
test "position_bk horizontalCompaction separates classes with appropriate sep" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 75.0)
  g.set_graph(graph)
  g.set_node("a", label=position_bk_node(100.0, 0, 0))
  g.set_node("b", label=position_bk_node(200.0, 0, 1))
  g.set_node("c", label=position_bk_node(50.0, 1, 0))
  g.set_node("d", label=position_bk_node(80.0, 1, 1))
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  root.set("c", "c")
  root.set("d", "b")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  align.set("b", "d")
  align.set("c", "c")
  align.set("d", "b")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  let b = 100.0 / 2.0 + 75.0 + 200.0 / 2.0
  assert_eq(xs.get_or_default("b", -1.0), b)
  assert_eq(xs.get_or_default("d", -1.0), b)
  assert_eq(xs.get_or_default("c", -1.0), b - 80.0 / 2.0 - 75.0 - 50.0 / 2.0)
}

///|
test "position_bk horizontalCompaction shifts classes by max sep #1" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 75.0)
  g.set_graph(graph)
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(150.0, 0, 1))
  g.set_node("c", label=position_bk_node(60.0, 1, 0))
  g.set_node("d", label=position_bk_node(70.0, 1, 1))
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  root.set("c", "a")
  root.set("d", "b")
  let align : Map[String, String] = Map::new()
  align.set("a", "c")
  align.set("b", "d")
  align.set("c", "a")
  align.set("d", "b")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  let b = 50.0 / 2.0 + 75.0 + 150.0 / 2.0
  assert_eq(xs.get_or_default("b", -1.0), b)
  assert_eq(xs.get_or_default("c", -1.0), 0.0)
  assert_eq(xs.get_or_default("d", -1.0), b)
}

///|
test "position_bk horizontalCompaction shifts classes by max sep #2" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 75.0)
  g.set_graph(graph)
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(70.0, 0, 1))
  g.set_node("c", label=position_bk_node(60.0, 1, 0))
  g.set_node("d", label=position_bk_node(150.0, 1, 1))
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  root.set("c", "a")
  root.set("d", "b")
  let align : Map[String, String] = Map::new()
  align.set("a", "c")
  align.set("b", "d")
  align.set("c", "a")
  align.set("d", "b")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  let b = 60.0 / 2.0 + 75.0 + 150.0 / 2.0
  assert_eq(xs.get_or_default("b", -1.0), b)
  assert_eq(xs.get_or_default("c", -1.0), 0.0)
  assert_eq(xs.get_or_default("d", -1.0), b)
}

///|
test "position_bk horizontalCompaction cascades class shift" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 75.0)
  g.set_graph(graph)
  for v in ["a", "b", "c", "d", "e", "f", "g"] {
    g.set_node(v, label=position_bk_node(50.0, 0, 0))
  }
  g.node("b").set_int("order", 1)
  g.node("c").set_int("rank", 1)
  g.node("d").set_int("rank", 1)
  g.node("d").set_int("order", 1)
  g.node("e").set_int("rank", 1)
  g.node("e").set_int("order", 2)
  g.node("f").set_int("rank", 2)
  g.node("g").set_int("rank", 2)
  g.node("g").set_int("order", 1)
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  root.set("c", "c")
  root.set("d", "d")
  root.set("e", "b")
  root.set("f", "f")
  root.set("g", "d")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  align.set("b", "e")
  align.set("c", "c")
  align.set("d", "g")
  align.set("e", "b")
  align.set("f", "f")
  align.set("g", "d")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(
    xs.get_or_default("a", 0.0),
    xs.get_or_default("b", 0.0) - 50.0 / 2.0 - 75.0 - 50.0 / 2.0,
  )
  assert_eq(xs.get_or_default("b", 0.0), xs.get_or_default("e", 0.0))
  assert_eq(xs.get_or_default("c", 0.0), xs.get_or_default("f", 0.0))
  assert_eq(
    xs.get_or_default("d", 0.0),
    xs.get_or_default("c", 0.0) + 50.0 / 2.0 + 75.0 + 50.0 / 2.0,
  )
  assert_eq(
    xs.get_or_default("e", 0.0),
    xs.get_or_default("d", 0.0) + 50.0 / 2.0 + 75.0 + 50.0 / 2.0,
  )
  assert_eq(
    xs.get_or_default("g", 0.0),
    xs.get_or_default("f", 0.0) + 50.0 / 2.0 + 75.0 + 50.0 / 2.0,
  )
}

///|
test "position_bk horizontalCompaction handles labelpos = l" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("edgesep", 50.0)
  g.set_graph(graph)
  let a = position_bk_node(100.0, 0, 0)
  a.set_string("dummy", "edge")
  g.set_node("a", label=a)
  let b = position_bk_node(200.0, 0, 1)
  b.set_string("dummy", "edge-label")
  b.set_string("labelpos", "l")
  g.set_node("b", label=b)
  let c = position_bk_node(300.0, 0, 2)
  c.set_string("dummy", "edge")
  g.set_node("c", label=c)
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  root.set("c", "c")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  align.set("b", "b")
  align.set("c", "c")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  assert_eq(
    xs.get_or_default("b", 0.0),
    xs.get_or_default("a", 0.0) + 100.0 / 2.0 + 50.0 + 200.0,
  )
  assert_eq(
    xs.get_or_default("c", 0.0),
    xs.get_or_default("b", 0.0) + 0.0 + 50.0 + 300.0 / 2.0,
  )
}

///|
test "position_bk horizontalCompaction handles labelpos = c" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("edgesep", 50.0)
  g.set_graph(graph)
  let a = position_bk_node(100.0, 0, 0)
  a.set_string("dummy", "edge")
  g.set_node("a", label=a)
  let b = position_bk_node(200.0, 0, 1)
  b.set_string("dummy", "edge-label")
  b.set_string("labelpos", "c")
  g.set_node("b", label=b)
  let c = position_bk_node(300.0, 0, 2)
  c.set_string("dummy", "edge")
  g.set_node("c", label=c)
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  root.set("c", "c")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  align.set("b", "b")
  align.set("c", "c")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  assert_eq(
    xs.get_or_default("b", 0.0),
    xs.get_or_default("a", 0.0) + 100.0 / 2.0 + 50.0 + 200.0 / 2.0,
  )
  assert_eq(
    xs.get_or_default("c", 0.0),
    xs.get_or_default("b", 0.0) + 200.0 / 2.0 + 50.0 + 300.0 / 2.0,
  )
}

///|
test "position_bk horizontalCompaction handles labelpos = r" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("edgesep", 50.0)
  g.set_graph(graph)
  let a = position_bk_node(100.0, 0, 0)
  a.set_string("dummy", "edge")
  g.set_node("a", label=a)
  let b = position_bk_node(200.0, 0, 1)
  b.set_string("dummy", "edge-label")
  b.set_string("labelpos", "r")
  g.set_node("b", label=b)
  let c = position_bk_node(300.0, 0, 2)
  c.set_string("dummy", "edge")
  g.set_node("c", label=c)
  let root : Map[String, String] = Map::new()
  root.set("a", "a")
  root.set("b", "b")
  root.set("c", "c")
  let align : Map[String, String] = Map::new()
  align.set("a", "a")
  align.set("b", "b")
  align.set("c", "c")
  let xs = position_bk_horizontal_compaction(
    g,
    build_layer_matrix(g),
    root,
    align,
  )
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  assert_eq(
    xs.get_or_default("b", 0.0),
    xs.get_or_default("a", 0.0) + 100.0 / 2.0 + 50.0 + 0.0,
  )
  assert_eq(
    xs.get_or_default("c", 0.0),
    xs.get_or_default("b", 0.0) + 200.0 + 50.0 + 300.0 / 2.0,
  )
}

///|
test "position_bk alignCoordinates aligns single node" {
  let xss : Map[String, Map[String, Double]] = Map::new()
  let ul : Map[String, Double] = Map::new()
  ul.set("a", 50.0)
  let ur : Map[String, Double] = Map::new()
  ur.set("a", 100.0)
  let dl : Map[String, Double] = Map::new()
  dl.set("a", 50.0)
  let dr : Map[String, Double] = Map::new()
  dr.set("a", 200.0)
  xss.set("ul", ul)
  xss.set("ur", ur)
  xss.set("dl", dl)
  xss.set("dr", dr)
  position_bk_align_coordinates(xss, ul)
  assert_eq(
    xss.get_or_default("ul", Map::new()).get_or_default("a", -1.0),
    50.0,
  )
  assert_eq(
    xss.get_or_default("ur", Map::new()).get_or_default("a", -1.0),
    50.0,
  )
  assert_eq(
    xss.get_or_default("dl", Map::new()).get_or_default("a", -1.0),
    50.0,
  )
  assert_eq(
    xss.get_or_default("dr", Map::new()).get_or_default("a", -1.0),
    50.0,
  )
}

///|
test "position_bk alignCoordinates aligns multiple nodes" {
  let xss : Map[String, Map[String, Double]] = Map::new()
  let ul : Map[String, Double] = Map::new()
  ul.set("a", 50.0)
  ul.set("b", 1000.0)
  let ur : Map[String, Double] = Map::new()
  ur.set("a", 100.0)
  ur.set("b", 900.0)
  let dl : Map[String, Double] = Map::new()
  dl.set("a", 150.0)
  dl.set("b", 800.0)
  let dr : Map[String, Double] = Map::new()
  dr.set("a", 200.0)
  dr.set("b", 700.0)
  xss.set("ul", ul)
  xss.set("ur", ur)
  xss.set("dl", dl)
  xss.set("dr", dr)
  position_bk_align_coordinates(xss, ul)
  assert_eq(
    xss.get_or_default("ul", Map::new()).get_or_default("a", -1.0),
    50.0,
  )
  assert_eq(
    xss.get_or_default("ul", Map::new()).get_or_default("b", -1.0),
    1000.0,
  )
  assert_eq(
    xss.get_or_default("ur", Map::new()).get_or_default("a", -1.0),
    200.0,
  )
  assert_eq(
    xss.get_or_default("ur", Map::new()).get_or_default("b", -1.0),
    1000.0,
  )
  assert_eq(
    xss.get_or_default("dl", Map::new()).get_or_default("a", -1.0),
    50.0,
  )
  assert_eq(
    xss.get_or_default("dl", Map::new()).get_or_default("b", -1.0),
    700.0,
  )
  assert_eq(
    xss.get_or_default("dr", Map::new()).get_or_default("a", -1.0),
    500.0,
  )
  assert_eq(
    xss.get_or_default("dr", Map::new()).get_or_default("b", -1.0),
    1000.0,
  )
}

///|
test "position_bk findSmallestWidthAlignment chooses smallest width" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 50.0)
  let b = empty_attrs()
  b.set_float("width", 50.0)
  g.set_node("a", label=a)
  g.set_node("b", label=b)
  let xss : Map[String, Map[String, Double]] = Map::new()
  let ul : Map[String, Double] = Map::new()
  ul.set("a", 0.0)
  ul.set("b", 1000.0)
  let ur : Map[String, Double] = Map::new()
  ur.set("a", -5.0)
  ur.set("b", 1000.0)
  let dl : Map[String, Double] = Map::new()
  dl.set("a", 5.0)
  dl.set("b", 2000.0)
  let dr : Map[String, Double] = Map::new()
  dr.set("a", 0.0)
  dr.set("b", 200.0)
  xss.set("ul", ul)
  xss.set("ur", ur)
  xss.set("dl", dl)
  xss.set("dr", dr)
  let smallest = position_bk_find_smallest_width_alignment(g, xss)
  assert_eq(smallest.get_or_default("a", 999.0), 0.0)
  assert_eq(smallest.get_or_default("b", 999.0), 200.0)
}

///|
test "position_bk findSmallestWidthAlignment takes node width into account" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 50.0)
  let b = empty_attrs()
  b.set_float("width", 50.0)
  let c = empty_attrs()
  c.set_float("width", 200.0)
  g.set_node("a", label=a)
  g.set_node("b", label=b)
  g.set_node("c", label=c)
  let xss : Map[String, Map[String, Double]] = Map::new()
  let ul : Map[String, Double] = Map::new()
  ul.set("a", 0.0)
  ul.set("b", 100.0)
  ul.set("c", 75.0)
  let ur : Map[String, Double] = Map::new()
  ur.set("a", 0.0)
  ur.set("b", 100.0)
  ur.set("c", 80.0)
  let dl : Map[String, Double] = Map::new()
  dl.set("a", 0.0)
  dl.set("b", 100.0)
  dl.set("c", 85.0)
  let dr : Map[String, Double] = Map::new()
  dr.set("a", 0.0)
  dr.set("b", 100.0)
  dr.set("c", 90.0)
  xss.set("ul", ul)
  xss.set("ur", ur)
  xss.set("dl", dl)
  xss.set("dr", dr)
  let smallest = position_bk_find_smallest_width_alignment(g, xss)
  assert_eq(smallest.get_or_default("c", -1.0), 75.0)
}

///|
test "position_bk balance single node median" {
  let xss : Map[String, Map[String, Double]] = Map::new()
  let ul : Map[String, Double] = Map::new()
  ul.set("a", 0.0)
  let ur : Map[String, Double] = Map::new()
  ur.set("a", 100.0)
  let dl : Map[String, Double] = Map::new()
  dl.set("a", 100.0)
  let dr : Map[String, Double] = Map::new()
  dr.set("a", 200.0)
  xss.set("ul", ul)
  xss.set("ur", ur)
  xss.set("dl", dl)
  xss.set("dr", dr)
  let out = position_bk_balance(xss)
  assert_eq(out.get_or_default("a", -1.0), 100.0)
}

///|
test "position_bk balance single node average of different medians" {
  let xss : Map[String, Map[String, Double]] = Map::new()
  let ul : Map[String, Double] = Map::new()
  ul.set("a", 0.0)
  let ur : Map[String, Double] = Map::new()
  ur.set("a", 75.0)
  let dl : Map[String, Double] = Map::new()
  dl.set("a", 125.0)
  let dr : Map[String, Double] = Map::new()
  dr.set("a", 200.0)
  xss.set("ul", ul)
  xss.set("ur", ur)
  xss.set("dl", dl)
  xss.set("dr", dr)
  let out = position_bk_balance(xss)
  assert_eq(out.get_or_default("a", -1.0), 100.0)
}

///|
test "position_bk balance multiple nodes" {
  let xss : Map[String, Map[String, Double]] = Map::new()
  let ul : Map[String, Double] = Map::new()
  ul.set("a", 0.0)
  ul.set("b", 50.0)
  let ur : Map[String, Double] = Map::new()
  ur.set("a", 75.0)
  ur.set("b", 0.0)
  let dl : Map[String, Double] = Map::new()
  dl.set("a", 125.0)
  dl.set("b", 60.0)
  let dr : Map[String, Double] = Map::new()
  dr.set("a", 200.0)
  dr.set("b", 75.0)
  xss.set("ul", ul)
  xss.set("ur", ur)
  xss.set("dl", dl)
  xss.set("dr", dr)
  let out = position_bk_balance(xss)
  assert_eq(out.get_or_default("a", -1.0), 100.0)
  assert_eq(out.get_or_default("b", -1.0), 55.0)
}

///|
test "position_bk positionX single node at origin" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(100.0, 0, 0))
  let xs = position_bk_x(g)
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
}

///|
test "position_bk positionX single block at origin" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(100.0, 0, 0))
  g.set_node("b", label=position_bk_node(100.0, 1, 0))
  g.set_edge("a", "b", label=attrs_value(empty_attrs()))
  let xs = position_bk_x(g)
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  assert_eq(xs.get_or_default("b", -1.0), 0.0)
}

///|
test "position_bk positionX single block at origin even when sizes differ" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_node("a", label=position_bk_node(40.0, 0, 0))
  g.set_node("b", label=position_bk_node(500.0, 1, 0))
  g.set_node("c", label=position_bk_node(20.0, 2, 0))
  g.set_path(["a", "b", "c"], label=attrs_value(empty_attrs()))
  let xs = position_bk_x(g)
  assert_eq(xs.get_or_default("a", -1.0), 0.0)
  assert_eq(xs.get_or_default("b", -1.0), 0.0)
  assert_eq(xs.get_or_default("c", -1.0), 0.0)
}

///|
test "position_bk positionX centers predecessor of two equal nodes" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 10.0)
  g.set_graph(graph)
  g.set_node("a", label=position_bk_node(20.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 1, 0))
  g.set_node("c", label=position_bk_node(50.0, 1, 1))
  g.set_edge("a", "b", label=attrs_value(empty_attrs()))
  g.set_edge("a", "c", label=attrs_value(empty_attrs()))
  let xs = position_bk_x(g)
  let a = xs.get_or_default("a", 0.0)
  assert_eq(xs.get_or_default("b", 0.0), a - (25.0 + 5.0))
  assert_eq(xs.get_or_default("c", 0.0), a + (25.0 + 5.0))
}

///|
test "position_bk positionX shifts blocks on both sides of aligned block" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 10.0)
  g.set_graph(graph)
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(60.0, 0, 1))
  g.set_node("c", label=position_bk_node(70.0, 1, 0))
  g.set_node("d", label=position_bk_node(80.0, 1, 1))
  g.set_edge("b", "c", label=attrs_value(empty_attrs()))
  let pos = position_bk_x(g)
  let b = pos.get_or_default("b", 0.0)
  let c = b
  assert_eq(pos.get_or_default("a", 0.0), b - 60.0 / 2.0 - 10.0 - 50.0 / 2.0)
  assert_eq(pos.get_or_default("b", 0.0), b)
  assert_eq(pos.get_or_default("c", 0.0), c)
  assert_eq(pos.get_or_default("d", 0.0), c + 70.0 / 2.0 + 10.0 + 80.0 / 2.0)
}

///|
test "position_bk positionX aligns inner segments" {
  let g = Graph::new()
  let graph = empty_attrs()
  graph.set_float("nodesep", 10.0)
  graph.set_float("edgesep", 10.0)
  g.set_graph(graph)
  let a = position_bk_node(50.0, 0, 0)
  a.set_bool("dummy", true)
  g.set_node("a", label=a)
  g.set_node("b", label=position_bk_node(60.0, 0, 1))
  g.set_node("c", label=position_bk_node(70.0, 1, 0))
  let d = position_bk_node(80.0, 1, 1)
  d.set_bool("dummy", true)
  g.set_node("d", label=d)
  g.set_edge("b", "c", label=attrs_value(empty_attrs()))
  g.set_edge("a", "d", label=attrs_value(empty_attrs()))
  let pos = position_bk_x(g)
  let ax = pos.get_or_default("a", 0.0)
  let dx = ax
  assert_eq(pos.get_or_default("a", 0.0), ax)
  assert_eq(pos.get_or_default("d", 0.0), dx)
  assert_eq(pos.get_or_default("b", 0.0), ax + 50.0 / 2.0 + 10.0 + 60.0 / 2.0)
  assert_eq(pos.get_or_default("c", 0.0), dx - 70.0 / 2.0 - 10.0 - 80.0 / 2.0)
}

///|
test "position_bk_x returns empty result for empty graph" {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  let xs = position_bk_x(g)
  assert_eq(xs.length(), 0)
}

///|
fn position_bk_crossing_fixture() -> Graph {
  let g = Graph::new()
  g.set_graph(empty_attrs())
  g.set_default_edge_label(() => attrs_value(empty_attrs()))
  g.set_node("a", label=position_bk_node(50.0, 0, 0))
  g.set_node("b", label=position_bk_node(50.0, 0, 1))
  g.set_node("c", label=position_bk_node(50.0, 1, 0))
  g.set_node("d", label=position_bk_node(50.0, 1, 1))
  g.set_edge("a", "d", label=attrs_value(empty_attrs()))
  g.set_edge("b", "c", label=attrs_value(empty_attrs()))
  g
}

///|
fn position_bk_node(width : Double, rank : Int, order : Int) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_float("width", width)
  attrs.set_float("height", 10.0)
  attrs.set_int("rank", rank)
  attrs.set_int("order", order)
  attrs
}

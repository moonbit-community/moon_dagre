///|
// Upstream: dagre-reference/test/layout-test.js
test "layout can position a single node" {
  let g = Graph::new(multigraph=true, compound=true)
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  ignore(layout(g))
  assert_eq(g.node("a").get_float_or("x", -1.0), 25.0)
  assert_eq(g.node("a").get_float_or("y", -1.0), 50.0)
}

///|
test "layout can position two nodes on same rank and respects nodesep" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("nodesep", 200.0)
  g.set_graph(graph)
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_float("width", 75.0)
  b.set_float("height", 200.0)
  g.set_node("b", label=b)
  ignore(layout(g))
  let xa = g.node("a").get_float_or("x", -1.0)
  let xb = g.node("b").get_float_or("x", -1.0)
  assert_eq(xb, xa + 50.0 / 2.0 + 200.0 + 75.0 / 2.0)
}

///|
test "layout can position two connected nodes and respects ranksep" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("ranksep", 300.0)
  g.set_graph(graph)
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_float("width", 75.0)
  b.set_float("height", 200.0)
  g.set_node("b", label=b)
  g.set_edge("a", "b")
  ignore(layout(g))
  let ya = g.node("a").get_float_or("y", -1.0)
  let yb = g.node("b").get_float_or("y", -1.0)
  assert_eq(yb, ya + 100.0 / 2.0 + 300.0 + 200.0 / 2.0)
  let edge = if value_as_attrs(g.edge("a", "b")) is Some(edge) {
    edge
  } else {
    empty_attrs()
  }
  assert_eq(edge.get_float("x") is None, true)
  assert_eq(edge.get_float("y") is None, true)
}

///|
test "layout can position edge label" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("ranksep", 300.0)
  g.set_graph(graph)
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_float("width", 75.0)
  b.set_float("height", 200.0)
  g.set_node("b", label=b)
  let edge = empty_attrs()
  edge.set_float("width", 60.0)
  edge.set_float("height", 70.0)
  edge.set_string("labelpos", "c")
  g.set_edge("a", "b", label=attrs_value(edge))
  ignore(layout(g))
  let e = if value_as_attrs(g.edge("a", "b")) is Some(e) {
    e
  } else {
    empty_attrs()
  }
  assert_eq(e.get_float("x") is Some(_), true)
  assert_eq(e.get_float("y") is Some(_), true)
}

///|
test "layout adds graph dimensions" {
  let g = Graph::new(multigraph=true, compound=true)
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 100.0)
  a.set_float("height", 50.0)
  g.set_node("a", label=a)
  ignore(layout(g))
  assert_eq(g.graph().get_float_or("width", 0.0), 100.0)
  assert_eq(g.graph().get_float_or("height", 0.0), 50.0)
}

///|
test "layout can position long edge with label" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("ranksep", 300.0)
  g.set_graph(graph)
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  g.set_node("a", label=a)
  let b = empty_attrs()
  b.set_float("width", 75.0)
  b.set_float("height", 200.0)
  g.set_node("b", label=b)
  let edge = empty_attrs()
  edge.set_float("width", 60.0)
  edge.set_float("height", 70.0)
  edge.set_int("minlen", 2)
  edge.set_string("labelpos", "c")
  g.set_edge("a", "b", label=attrs_value(edge))
  ignore(layout(g))
  let e = if value_as_attrs(g.edge("a", "b")) is Some(e) {
    e
  } else {
    empty_attrs()
  }
  assert_eq(e.get_float_or("x", -1.0), 75.0 / 2.0)
  let ey = e.get_float_or("y", -1.0)
  assert_eq(ey > g.node("a").get_float_or("y", 0.0), true)
  assert_eq(ey < g.node("b").get_float_or("y", 0.0), true)
}

///|
test "layout can handle short cycle" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("ranksep", 200.0)
  g.set_graph(graph)
  let a = empty_attrs()
  a.set_float("width", 100.0)
  a.set_float("height", 100.0)
  let b = empty_attrs()
  b.set_float("width", 100.0)
  b.set_float("height", 100.0)
  g.set_node("a", label=a)
  g.set_node("b", label=b)
  let ab = empty_attrs()
  ab.set_float("weight", 2.0)
  g.set_edge("a", "b", label=attrs_value(ab))
  g.set_edge("b", "a")
  ignore(layout(g))
  assert_eq(g.node("a").get_float_or("x", -1.0), 50.0)
  assert_eq(g.node("a").get_float_or("y", -1.0), 50.0)
  assert_eq(g.node("b").get_float_or("x", -1.0), 50.0)
  assert_eq(g.node("b").get_float_or("y", -1.0), 350.0)
  let e1 = if value_as_attrs(g.edge("a", "b")) is Some(e) {
    e
  } else {
    empty_attrs()
  }
  let e2 = if value_as_attrs(g.edge("b", "a")) is Some(e) {
    e
  } else {
    empty_attrs()
  }
  if e1.get_points("points") is Some(p1) && e2.get_points("points") is Some(p2) {
    assert_eq(p1[1].y > p1[0].y, true)
    assert_eq(p2[0].y > p2[1].y, true)
  } else {
    assert_eq(false, true)
  }
}

///|
test "layout adds rectangle intersects for edge" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("ranksep", 200.0)
  g.set_graph(graph)
  let n = empty_attrs()
  n.set_float("width", 100.0)
  n.set_float("height", 100.0)
  g.set_node("a", label=clone_attrs(n))
  g.set_node("b", label=clone_attrs(n))
  g.set_edge("a", "b")
  ignore(layout(g))
  let e = if value_as_attrs(g.edge("a", "b")) is Some(e) {
    e
  } else {
    empty_attrs()
  }
  if e.get_points("points") is Some(points) {
    assert_eq(points.length(), 3)
    assert_eq(points[0].x, 50.0)
    assert_eq(points[0].y, 100.0)
    assert_eq(points[1].x, 50.0)
    assert_eq(points[1].y, 200.0)
    assert_eq(points[2].x, 50.0)
    assert_eq(points[2].y, 300.0)
  } else {
    assert_eq(false, true)
  }
}

///|
test "layout adds rectangle intersects for edge spanning multiple ranks" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("ranksep", 200.0)
  g.set_graph(graph)
  let n = empty_attrs()
  n.set_float("width", 100.0)
  n.set_float("height", 100.0)
  g.set_node("a", label=clone_attrs(n))
  g.set_node("b", label=clone_attrs(n))
  let edge = empty_attrs()
  edge.set_int("minlen", 2)
  g.set_edge("a", "b", label=attrs_value(edge))
  ignore(layout(g))
  let e = if value_as_attrs(g.edge("a", "b")) is Some(e) {
    e
  } else {
    empty_attrs()
  }
  if e.get_points("points") is Some(points) {
    assert_eq(points.length(), 5)
    assert_eq(points[0].y, 100.0)
    assert_eq(points[1].y, 200.0)
    assert_eq(points[2].y, 300.0)
    assert_eq(points[3].y, 400.0)
    assert_eq(points[4].y, 500.0)
  } else {
    assert_eq(false, true)
  }
}

///|
test "layout supports long labels across rankdir variants" {
  for rankdir in ["TB", "BT", "LR", "RL"] {
    let g = Graph::new(multigraph=true, compound=true)
    let graph = empty_attrs()
    graph.set_float("nodesep", 10.0)
    graph.set_float("edgesep", 10.0)
    graph.set_string("rankdir", rankdir)
    g.set_graph(graph)
    for v in ["a", "b", "c", "d"] {
      let node = empty_attrs()
      node.set_float("width", 10.0)
      node.set_float("height", 10.0)
      g.set_node(v, label=node)
    }
    let long = empty_attrs()
    long.set_float("width", 2000.0)
    long.set_float("height", 10.0)
    long.set_string("labelpos", "c")
    g.set_edge("a", "c", label=attrs_value(long))
    let short = empty_attrs()
    short.set_float("width", 1.0)
    short.set_float("height", 1.0)
    g.set_edge("b", "d", label=attrs_value(short))
    ignore(layout(g))
    if rankdir == "TB" || rankdir == "BT" {
      let p1 = if value_as_attrs(g.edge("a", "c")) is Some(e) {
        e
      } else {
        empty_attrs()
      }
      let p2 = if value_as_attrs(g.edge("b", "d")) is Some(e) {
        e
      } else {
        empty_attrs()
      }
      assert_eq(
        (p1.get_float_or("x", 0.0) - p2.get_float_or("x", 0.0)).abs() > 1000.0,
        true,
      )
    } else {
      assert_eq(
        (g.node("a").get_float_or("x", 0.0) - g.node("c").get_float_or("x", 0.0)).abs() >
        1000.0,
        true,
      )
    }
  }
}

///|
test "layout applies labeloffset across rankdir variants" {
  for rankdir in ["TB", "BT", "LR", "RL"] {
    let g = Graph::new(multigraph=true, compound=true)
    let graph = empty_attrs()
    graph.set_float("nodesep", 10.0)
    graph.set_float("edgesep", 10.0)
    graph.set_string("rankdir", rankdir)
    g.set_graph(graph)
    for v in ["a", "b", "c", "d"] {
      let node = empty_attrs()
      node.set_float("width", 10.0)
      node.set_float("height", 10.0)
      g.set_node(v, label=node)
    }
    let left = empty_attrs()
    left.set_float("width", 10.0)
    left.set_float("height", 10.0)
    left.set_string("labelpos", "l")
    left.set_float("labeloffset", 1000.0)
    g.set_edge("a", "b", label=attrs_value(left))
    let right = empty_attrs()
    right.set_float("width", 10.0)
    right.set_float("height", 10.0)
    right.set_string("labelpos", "r")
    right.set_float("labeloffset", 1000.0)
    g.set_edge("c", "d", label=attrs_value(right))
    ignore(layout(g))
    let ab = if value_as_attrs(g.edge("a", "b")) is Some(e) {
      e
    } else {
      empty_attrs()
    }
    let cd = if value_as_attrs(g.edge("c", "d")) is Some(e) {
      e
    } else {
      empty_attrs()
    }
    if rankdir == "TB" || rankdir == "BT" {
      if ab.get_points("points") is Some(ab_points) &&
        cd.get_points("points") is Some(cd_points) {
        assert_eq(
          ab.get_float_or("x", 0.0) - ab_points[0].x,
          -1000.0 - 10.0 / 2.0,
        )
        assert_eq(
          cd.get_float_or("x", 0.0) - cd_points[0].x,
          1000.0 + 10.0 / 2.0,
        )
      } else {
        assert_eq(false, true)
      }
    } else if ab.get_points("points") is Some(ab_points) &&
      cd.get_points("points") is Some(cd_points) {
      assert_eq(
        ab.get_float_or("y", 0.0) - ab_points[0].y,
        -1000.0 - 10.0 / 2.0,
      )
      assert_eq(cd.get_float_or("y", 0.0) - cd_points[0].y, 1000.0 + 10.0 / 2.0)
    } else {
      assert_eq(false, true)
    }
  }
}

///|
test "layout can position self loop in all rankdirs" {
  for rankdir in ["TB", "BT", "LR", "RL"] {
    let g = Graph::new(multigraph=true, compound=true)
    let graph = empty_attrs()
    graph.set_float("edgesep", 75.0)
    graph.set_string("rankdir", rankdir)
    g.set_graph(graph)
    let node = empty_attrs()
    node.set_float("width", 100.0)
    node.set_float("height", 100.0)
    g.set_node("a", label=node)
    let edge = empty_attrs()
    edge.set_float("width", 50.0)
    edge.set_float("height", 50.0)
    g.set_edge("a", "a", label=attrs_value(edge))
    ignore(layout(g))
    let a = g.node("a")
    let e = if value_as_attrs(g.edge("a", "a")) is Some(e) {
      e
    } else {
      empty_attrs()
    }
    if e.get_points("points") is Some(points) {
      assert_eq(points.length(), 7)
      for p in points {
        if rankdir != "LR" && rankdir != "RL" {
          assert_eq(p.x > a.get_float_or("x", 0.0), true)
          assert_eq(
            (p.y - a.get_float_or("y", 0.0)).abs() <=
            a.get_float_or("height", 0.0) / 2.0,
            true,
          )
        } else {
          assert_eq(p.y > a.get_float_or("y", 0.0), true)
          assert_eq(
            (p.x - a.get_float_or("x", 0.0)).abs() <=
            a.get_float_or("width", 0.0) / 2.0,
            true,
          )
        }
      }
    } else {
      assert_eq(false, true)
    }
  }
}

///|
test "layout supports subgraph smoke" {
  let g = Graph::new(multigraph=true, compound=true)
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 50.0)
  g.set_node("a", label=a)
  g.set_parent("a", parent="sg1")
  ignore(layout(g))
  assert_eq(g.has_node("a"), true)
}

///|
test "layout minimizes subgraph height" {
  let g = Graph::new(multigraph=true, compound=true)
  g.set_graph(empty_attrs())
  for v in ["a", "b", "c", "d", "x", "y"] {
    let node = empty_attrs()
    node.set_float("width", 50.0)
    node.set_float("height", 50.0)
    g.set_node(v, label=node)
  }
  g.set_path(["a", "b", "c", "d"])
  let w = empty_attrs()
  w.set_float("weight", 100.0)
  g.set_edge("a", "x", label=attrs_value(clone_attrs(w)))
  g.set_edge("y", "d", label=attrs_value(clone_attrs(w)))
  g.set_parent("x", parent="sg")
  g.set_parent("y", parent="sg")
  ignore(layout(g))
  assert_eq(
    g.node("x").get_float_or("y", -1.0),
    g.node("y").get_float_or("y", -2.0),
  )
}

///|
test "layout minimizes separation not adjacent to subgraphs" {
  let g = Graph::new(multigraph=true, compound=true)
  g.set_graph(empty_attrs())
  for v in ["a", "b", "c"] {
    let node = empty_attrs()
    node.set_float("width", 50.0)
    node.set_float("height", 50.0)
    g.set_node(v, label=node)
  }
  g.set_path(["a", "b", "c"])
  g.set_node("sg", label=empty_attrs())
  g.set_parent("c", parent="sg")
  ignore(layout(g))
  assert_eq(
    g.node("b").get_float_or("y", 0.0) - g.node("a").get_float_or("y", 0.0),
    100.0,
  )
}

///|
test "layout supports subgraphs with different rankdirs" {
  let g = Graph::new(multigraph=true, compound=true)
  g.set_graph(empty_attrs())
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 50.0)
  g.set_node("a", label=a)
  g.set_node("sg", label=empty_attrs())
  g.set_parent("a", parent="sg")
  for rankdir in ["tb", "bt", "lr", "rl"] {
    g.graph().set_string("rankdir", rankdir)
    ignore(layout(g))
    assert_eq(g.node("sg").get_float_or("width", 0.0) > 50.0, true)
    assert_eq(g.node("sg").get_float_or("height", 0.0) > 50.0, true)
    assert_eq(g.node("sg").get_float_or("x", 0.0) > 25.0, true)
    assert_eq(g.node("sg").get_float_or("y", 0.0) > 25.0, true)
  }
}

///|
test "layout keeps all coordinates in bounding box across rankdirs" {
  for rankdir in ["TB", "BT", "LR", "RL"] {
    let g1 = Graph::new(multigraph=true, compound=true)
    let graph1 = empty_attrs()
    graph1.set_string("rankdir", rankdir)
    g1.set_graph(graph1)
    let node = empty_attrs()
    node.set_float("width", 100.0)
    node.set_float("height", 200.0)
    g1.set_node("a", label=node)
    ignore(layout(g1))
    assert_eq(g1.node("a").get_float_or("x", -1.0), 50.0)
    assert_eq(g1.node("a").get_float_or("y", -1.0), 100.0)
    let g2 = Graph::new(multigraph=true, compound=true)
    let graph2 = empty_attrs()
    graph2.set_string("rankdir", rankdir)
    g2.set_graph(graph2)
    let n = empty_attrs()
    n.set_float("width", 100.0)
    n.set_float("height", 100.0)
    g2.set_node("a", label=clone_attrs(n))
    g2.set_node("b", label=clone_attrs(n))
    let e = empty_attrs()
    e.set_float("width", 1000.0)
    e.set_float("height", 2000.0)
    e.set_string("labelpos", "l")
    e.set_float("labeloffset", 0.0)
    g2.set_edge("a", "b", label=attrs_value(e))
    ignore(layout(g2))
    let edge = if value_as_attrs(g2.edge("a", "b")) is Some(edge) {
      edge
    } else {
      empty_attrs()
    }
    if rankdir == "TB" || rankdir == "BT" {
      assert_eq(edge.get_float_or("x", -1.0), 500.0)
    } else {
      assert_eq(edge.get_float_or("y", -1.0), 1000.0)
    }
  }
}

///|
test "layout treats attributes with case-insensitivity" {
  let g = Graph::new(multigraph=true, compound=true)
  let graph = empty_attrs()
  graph.set_float("nodeSep", 200.0)
  g.set_graph(graph)
  let a = empty_attrs()
  a.set_float("width", 50.0)
  a.set_float("height", 100.0)
  let b = empty_attrs()
  b.set_float("width", 75.0)
  b.set_float("height", 200.0)
  g.set_node("a", label=a)
  g.set_node("b", label=b)
  ignore(layout(g))
  let xa = g.node("a").get_float_or("x", -1.0)
  let xb = g.node("b").get_float_or("x", -1.0)
  assert_eq(xb, xa + 50.0 / 2.0 + 200.0 + 75.0 / 2.0)
}

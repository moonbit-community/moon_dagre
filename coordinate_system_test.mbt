///|
// Upstream: dagre-reference/test/coordinate-system-test.js
test "coordinate_adjust keeps dims for TB" {
  let g = graph_with_node_dims(100.0, 200.0)
  g.set_graph(graph_rankdir("TB"))
  coordinate_adjust(g)
  inspect(node_dims(g), content="(100, 200)")
}

///|
test "coordinate_adjust keeps dims for BT" {
  let g = graph_with_node_dims(100.0, 200.0)
  g.set_graph(graph_rankdir("BT"))
  coordinate_adjust(g)
  inspect(node_dims(g), content="(100, 200)")
}

///|
test "coordinate_adjust swaps dims for LR" {
  let g = graph_with_node_dims(100.0, 200.0)
  g.set_graph(graph_rankdir("LR"))
  coordinate_adjust(g)
  inspect(node_dims(g), content="(200, 100)")
}

///|
test "coordinate_adjust swaps dims for RL" {
  let g = graph_with_node_dims(100.0, 200.0)
  g.set_graph(graph_rankdir("RL"))
  coordinate_adjust(g)
  inspect(node_dims(g), content="(200, 100)")
}

///|
test "coordinate_undo keeps node for TB" {
  let g = graph_with_node_frame(100.0, 200.0, 20.0, 40.0)
  g.set_graph(graph_rankdir("TB"))
  coordinate_undo(g)
  inspect(node_frame(g), content="(20, 40, 100, 200)")
}

///|
test "coordinate_undo flips y for BT" {
  let g = graph_with_node_frame(100.0, 200.0, 20.0, 40.0)
  g.set_graph(graph_rankdir("BT"))
  coordinate_undo(g)
  inspect(node_frame(g), content="(20, -40, 100, 200)")
}

///|
test "coordinate_undo swaps coords and dims for LR" {
  let g = graph_with_node_frame(100.0, 200.0, 20.0, 40.0)
  g.set_graph(graph_rankdir("LR"))
  coordinate_undo(g)
  inspect(node_frame(g), content="(40, 20, 200, 100)")
}

///|
test "coordinate_undo swaps, flips x, swaps dims for RL" {
  let g = graph_with_node_frame(100.0, 200.0, 20.0, 40.0)
  g.set_graph(graph_rankdir("RL"))
  coordinate_undo(g)
  inspect(node_frame(g), content="(-40, 20, 200, 100)")
}

///|
fn graph_with_node_dims(width : Double, height : Double) -> Graph {
  let g = Graph::new()
  g.set_node("a", label=node_dims_attrs(width, height))
  g
}

///|
fn graph_with_node_frame(
  width : Double,
  height : Double,
  x : Double,
  y : Double,
) -> Graph {
  let g = Graph::new()
  let attrs = node_dims_attrs(width, height)
  attrs.set_float("x", x)
  attrs.set_float("y", y)
  g.set_node("a", label=attrs)
  g
}

///|
fn node_dims_attrs(width : Double, height : Double) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_float("width", width)
  attrs.set_float("height", height)
  attrs
}

///|
fn graph_rankdir(rankdir : String) -> Attrs {
  let attrs = empty_attrs()
  attrs.set_string("rankdir", rankdir)
  attrs
}

///|
fn node_dims(g : Graph) -> (Double, Double) {
  let node = g.node("a")
  (node.get_float_or("width", 0.0), node.get_float_or("height", 0.0))
}

///|
fn node_frame(g : Graph) -> (Double, Double, Double, Double) {
  let node = g.node("a")
  (
    node.get_float_or("x", 0.0),
    node.get_float_or("y", 0.0),
    node.get_float_or("width", 0.0),
    node.get_float_or("height", 0.0),
  )
}

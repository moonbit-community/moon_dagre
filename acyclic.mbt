///|
pub fn acyclic_run(g : Graph) -> Unit {
  let acyclicer = g.graph().get_string_or("acyclicer", "")
  let fas = if acyclicer == "greedy" {
    greedy_fas(g, weight_fn=weight_fn(g))
  } else {
    dfs_fas_core(g)
  }
  for e in fas {
    if g.edge_obj(e) is Some(label) {
      g.remove_edge_obj(e)
      let reversed = as_attrs_label(label)
      reversed.set_bool("reversed", true)
      if e.name is Some(name) {
        reversed.set_string("forwardName", name)
      }
      g.set_edge(e.w, e.v, label=Value::VAttrs(reversed), name=unique_id("rev"))
    }
  }
}

///|
fn weight_fn(g : Graph) -> (EdgeObj) -> Double {
  (e : EdgeObj) => {
    match g.edge_obj(e) {
      Some(Value::VAttrs(attrs)) => attrs.get_float_or("weight", 1.0)
      Some(Value::VInt(v)) => v.to_double()
      Some(Value::VFloat(v)) => v
      _ => 1.0
    }
  }
}

///|
fn dfs_fas_core(g : Graph) -> Array[EdgeObj] {
  let node_ids : Map[String, Int] = Map::new()
  let mut nodes = @acyclic_dfs.DfsIntList::NoDfsInts
  let graph_nodes = g.nodes()
  for i in 0..<graph_nodes.length() {
    let v = graph_nodes[i]
    node_ids.set(v, i)
    nodes = dfs_int_list_push_local(nodes, i)
  }
  let graph_edges = g.edges()
  let mut edges = @acyclic_dfs.DfsEdgeList::NoDfsEdges
  for i in 0..<graph_edges.length() {
    let e = graph_edges[i]
    if node_ids.get(e.v) is Some(v) {
      if node_ids.get(e.w) is Some(w) {
        edges = dfs_edge_list_push_local(edges, { id: i, v, w })
      }
    }
  }
  let fas_ids = @acyclic_dfs.dfs_fas_edge_ids(nodes, edges)
  dfs_edge_ids_to_edge_objs(fas_ids, graph_edges)
}

///|
fn dfs_int_list_push_local(
  xs : @acyclic_dfs.DfsIntList,
  x : Int,
) -> @acyclic_dfs.DfsIntList {
  match xs {
    NoDfsInts => MoreDfsInt(x, NoDfsInts)
    MoreDfsInt(y, rest) => MoreDfsInt(y, dfs_int_list_push_local(rest, x))
  }
}

///|
fn dfs_edge_list_push_local(
  xs : @acyclic_dfs.DfsEdgeList,
  edge : @acyclic_dfs.DfsEdge,
) -> @acyclic_dfs.DfsEdgeList {
  match xs {
    NoDfsEdges => MoreDfsEdge(edge, NoDfsEdges)
    MoreDfsEdge(e, rest) => MoreDfsEdge(e, dfs_edge_list_push_local(rest, edge))
  }
}

///|
fn dfs_edge_ids_to_edge_objs(
  ids : @acyclic_dfs.DfsIntList,
  graph_edges : Array[EdgeObj],
) -> Array[EdgeObj] {
  match ids {
    NoDfsInts => []
    MoreDfsInt(id, rest) => {
      let out = dfs_edge_ids_to_edge_objs(rest, graph_edges)
      if id >= 0 && id < graph_edges.length() {
        out.push(graph_edges[id])
      }
      out
    }
  }
}

///|
pub fn acyclic_undo(g : Graph) -> Unit {
  let edges = g.edges()
  for e in edges {
    if g.edge_obj(e) is Some(Value::VAttrs(label)) {
      if label.get_bool_or("reversed", false) {
        g.remove_edge_obj(e)
        let forward_name = label.get_string("forwardName")
        label.remove("reversed")
        label.remove("forwardName")
        let name = forward_name
        g.set_edge(e.w, e.v, label=Value::VAttrs(label), name?)
      }
    }
  }
}

///|
fn as_attrs_label(value : Value) -> Attrs {
  match value {
    Value::VAttrs(attrs) => clone_attrs(attrs)
    Value::VInt(v) => {
      let attrs = empty_attrs()
      attrs.set_float("weight", v.to_double())
      attrs
    }
    Value::VFloat(v) => {
      let attrs = empty_attrs()
      attrs.set_float("weight", v)
      attrs
    }
    Value::VBool(v) => {
      let attrs = empty_attrs()
      attrs.set_bool("value", v)
      attrs
    }
    Value::VString(v) => {
      let attrs = empty_attrs()
      attrs.set_string("value", v)
      attrs
    }
    Value::VNull => empty_attrs()
  }
}

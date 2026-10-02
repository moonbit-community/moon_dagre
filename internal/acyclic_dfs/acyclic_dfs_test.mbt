///|
test "dfs_fas_edge_ids returns empty for acyclic graph" {
  let nodes = int_list([0, 1, 2, 3])
  let edges = edge_list([
    { id: 0, v: 0, w: 1, },
    { id: 1, v: 0, w: 2, },
    { id: 2, v: 1, w: 3, },
    { id: 3, v: 2, w: 3, },
  ])
  debug_inspect(
    int_list_to_array(@acyclic_dfs.dfs_fas_edge_ids(nodes, edges)),
    content="[]",
  )
}

///|
test "dfs_fas_edge_ids records stack back edge" {
  let nodes = int_list([0, 1, 2, 3])
  let edges = edge_list([
    { id: 0, v: 0, w: 1, },
    { id: 1, v: 1, w: 2, },
    { id: 2, v: 2, w: 3, },
    { id: 3, v: 3, w: 0, },
  ])
  debug_inspect(
    int_list_to_array(@acyclic_dfs.dfs_fas_edge_ids(nodes, edges)),
    content="[3]",
  )
}

///|
fn int_list(values : Array[Int]) -> @acyclic_dfs.DfsIntList {
  let mut out = @acyclic_dfs.DfsIntList::NoDfsInts
  for value in values.rev_iter() {
    out = MoreDfsInt(value, out)
  }
  out
}

///|
fn edge_list(values : Array[@acyclic_dfs.DfsEdge]) -> @acyclic_dfs.DfsEdgeList {
  let mut out = @acyclic_dfs.DfsEdgeList::NoDfsEdges
  for value in values.rev_iter() {
    out = MoreDfsEdge(value, out)
  }
  out
}

///|
fn int_list_to_array(values : @acyclic_dfs.DfsIntList) -> Array[Int] {
  match values {
    NoDfsInts => []
    MoreDfsInt(value, rest) => {
      let out = int_list_to_array(rest)
      out.insert(0, value)
      out
    }
  }
}

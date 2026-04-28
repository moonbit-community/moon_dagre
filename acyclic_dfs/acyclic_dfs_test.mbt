///|
test "dfs_fas_edge_ids returns empty for acyclic graph" {
  let nodes = int_list([0, 1, 2, 3])
  let edges = edge_list([
    { id: 0, v: 0, w: 1 },
    { id: 1, v: 0, w: 2 },
    { id: 2, v: 1, w: 3 },
    { id: 3, v: 2, w: 3 },
  ])
  inspect(int_list_to_array(dfs_fas_edge_ids(nodes, edges)), content="[]")
}

///|
test "dfs_fas_edge_ids records stack back edge" {
  let nodes = int_list([0, 1, 2, 3])
  let edges = edge_list([
    { id: 0, v: 0, w: 1 },
    { id: 1, v: 1, w: 2 },
    { id: 2, v: 2, w: 3 },
    { id: 3, v: 3, w: 0 },
  ])
  inspect(int_list_to_array(dfs_fas_edge_ids(nodes, edges)), content="[3]")
}

///|
fn int_list(values : Array[Int]) -> DfsIntList {
  let mut out = DfsIntList::NoDfsInts
  for value in values.rev_iter() {
    out = DfsIntList::MoreDfsInt(value, out)
  }
  out
}

///|
fn edge_list(values : Array[DfsEdge]) -> DfsEdgeList {
  let mut out = DfsEdgeList::NoDfsEdges
  for value in values.rev_iter() {
    out = DfsEdgeList::MoreDfsEdge(value, out)
  }
  out
}

///|
fn int_list_to_array(values : DfsIntList) -> Array[Int] {
  match values {
    NoDfsInts => []
    MoreDfsInt(value, rest) => {
      let out = int_list_to_array(rest)
      out.insert(0, value)
      out
    }
  }
}

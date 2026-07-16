///|
pub(all) struct DfsEdge {
  id : Int
  v : Int
  w : Int
} derive(Compare, Eq)

///|
pub(all) enum DfsEdgeList {
  NoDfsEdges
  MoreDfsEdge(DfsEdge, DfsEdgeList)
}

///|
pub(all) enum DfsIntList {
  NoDfsInts
  MoreDfsInt(Int, DfsIntList)
} derive(Eq)

///|
priv struct DfsState {
  visited : DfsIntList
  stack : DfsIntList
  finished : DfsIntList
  fas : DfsIntList
}

///|
pub(all) struct DfsRun {
  fas : DfsIntList
  topo_order : DfsIntList
}

///|
pub fn dfs_fas_run(
  nodes : DfsIntList,
  edges : DfsEdgeList,
) -> DfsRun where {
  proof_require: dfs_edge_list_endpoints_in(edges, nodes),
  proof_ensure: result => {
    dfs_finished_edges_topological(edges, result.fas, result.topo_order)
  },
  proof_ensure: result => dfs_int_list_subset(nodes, result.topo_order),
  proof_ensure: result => {
    dfs_kept_edges_topological(edges, result.fas, result.topo_order)
  },
} {
  proof_assert dfs_int_list_subset(nodes, nodes)
  proof_assert dfs_active_partition({
    visited: NoDfsInts,
    stack: NoDfsInts,
    finished: NoDfsInts,
    fas: NoDfsInts,
  })
  proof_assert dfs_finished_edges_topological(edges, NoDfsInts, NoDfsInts)
  let state = dfs_all(nodes, nodes, edges, {
    visited: NoDfsInts,
    stack: NoDfsInts,
    finished: NoDfsInts,
    fas: NoDfsInts,
  })
  proof_assert dfs_edge_list_endpoints_in(edges, state.finished)
  proof_assert dfs_kept_edges_topological(edges, state.fas, state.finished)
  { fas: state.fas, topo_order: state.finished }
}

///|
pub fn dfs_fas_edge_ids(
  nodes : DfsIntList,
  edges : DfsEdgeList,
) -> DfsIntList where {
  proof_require: dfs_edge_list_endpoints_in(edges, nodes),
} {
  dfs_fas_run(nodes, edges).fas
}

///|
fn dfs_all(
  nodes : DfsIntList,
  all_nodes : DfsIntList,
  edges : DfsEdgeList,
  state : DfsState,
) -> DfsState where {
  proof_decrease: nodes,
  proof_require: dfs_int_list_subset(nodes, all_nodes),
  proof_require: dfs_edge_list_endpoints_in(edges, all_nodes),
  proof_require: dfs_active_partition(state),
  proof_require: dfs_int_list_empty(state.stack),
  proof_require: dfs_finished_edges_topological(
    edges,
    state.fas,
    state.finished,
  ),
  proof_ensure: result => dfs_active_partition(result),
  proof_ensure: result => dfs_int_list_empty(result.stack),
  proof_ensure: result => dfs_int_list_subset(nodes, result.finished),
  proof_ensure: result => dfs_int_list_subset(state.finished, result.finished),
  proof_ensure: result => {
    dfs_finished_edges_topological(edges, result.fas, result.finished)
  },
} {
  match nodes {
    NoDfsInts => state
    MoreDfsInt(v, rest) => {
      proof_assert dfs_int_list_mem(all_nodes, v)
      proof_assert !dfs_int_list_mem(state.stack, v)
      let state = dfs_visit(v, all_nodes, edges, state)
      proof_assert dfs_int_list_empty(state.stack)
      proof_assert dfs_int_list_mem(state.finished, v)
      proof_assert dfs_int_list_subset(rest, all_nodes)
      let state = dfs_all(rest, all_nodes, edges, state)
      proof_assert dfs_int_list_mem(state.finished, v)
      proof_assert dfs_int_list_subset(MoreDfsInt(v, rest), state.finished)
      state
    }
  }
}

///|
fn dfs_visit(
  v : Int,
  nodes : DfsIntList,
  edges : DfsEdgeList,
  state : DfsState,
) -> DfsState where {
  proof_decrease: dfs_visit_measure(nodes, edges, state),
  proof_require: dfs_int_list_mem(nodes, v),
  proof_require: dfs_edge_list_endpoints_in(edges, nodes),
  proof_require: dfs_active_partition(state),
  proof_require: !dfs_int_list_mem(state.stack, v),
  proof_require: dfs_finished_edges_topological(
    edges,
    state.fas,
    state.finished,
  ),
  proof_ensure: result => {
    dfs_unvisited_count(nodes, result.visited) <=
    dfs_unvisited_count(nodes, state.visited)
  },
  proof_ensure: result => {
    dfs_unvisited_budget(
      nodes,
      result.visited,
      dfs_edge_list_length_model(edges) + 2,
    ) <=
    dfs_unvisited_budget(
      nodes,
      state.visited,
      dfs_edge_list_length_model(edges) + 2,
    )
  },
  proof_ensure: result => dfs_active_partition(result),
  proof_ensure: result => dfs_int_list_same(result.stack, state.stack),
  proof_ensure: result => dfs_int_list_mem(result.finished, v),
  proof_ensure: result => {
    dfs_finished_edges_topological(edges, result.fas, result.finished)
  },
  proof_ensure: result => dfs_int_list_subset(state.fas, result.fas),
  proof_ensure: result => dfs_int_list_subset(state.finished, result.finished),
  proof_ensure: result => {
    dfs_int_list_mem(state.stack, v) || dfs_int_list_mem(result.finished, v)
  },
} {
  proof_assert 0 <= dfs_visit_measure(nodes, edges, state)
  if dfs_int_list_contains(state.visited, v) {
    state
  } else {
    let entered = {
      visited: MoreDfsInt(v, state.visited),
      stack: MoreDfsInt(v, state.stack),
      finished: state.finished,
      fas: state.fas,
    }
    proof_assert dfs_unvisited_count(nodes, entered.visited) <
      dfs_unvisited_count(nodes, state.visited)
    proof_assert 0 <= dfs_edge_list_length_model(edges)
    proof_assert dfs_unvisited_budget(
        nodes,
        entered.visited,
        dfs_edge_list_length_model(edges) + 2,
      ) +
      (dfs_edge_list_length_model(edges) + 2) <=
      dfs_unvisited_budget(
        nodes,
        state.visited,
        dfs_edge_list_length_model(edges) + 2,
      )
    proof_assert dfs_edge_list_length_model(edges) + 1 <
      dfs_edge_list_length_model(edges) + 2
    proof_assert dfs_visit_out_edges_measure(nodes, edges, edges, entered) <
      dfs_visit_measure(nodes, edges, state)
    let after_edges = dfs_visit_out_edges(v, nodes, edges, edges, entered)
    proof_assert dfs_unvisited_count(nodes, after_edges.visited) <=
      dfs_unvisited_count(nodes, entered.visited)
    proof_assert dfs_unvisited_budget(
        nodes,
        after_edges.visited,
        dfs_edge_list_length_model(edges) + 2,
      ) <=
      dfs_unvisited_budget(
        nodes,
        entered.visited,
        dfs_edge_list_length_model(edges) + 2,
      )
    proof_assert dfs_int_list_same(after_edges.stack, entered.stack)
    proof_assert dfs_active_partition_lists(
      after_edges.visited,
      entered.stack,
      after_edges.finished,
    )
    proof_assert dfs_active_partition_lists(
      after_edges.visited,
      MoreDfsInt(v, state.stack),
      after_edges.finished,
    )
    proof_assert dfs_active_partition_lists(
      after_edges.visited,
      state.stack,
      MoreDfsInt(v, after_edges.finished),
    )
    proof_assert dfs_finished_edges_topological(
      edges,
      after_edges.fas,
      MoreDfsInt(v, after_edges.finished),
    )
    {
      visited: after_edges.visited,
      stack: state.stack,
      finished: MoreDfsInt(v, after_edges.finished),
      fas: after_edges.fas,
    }
  }
}

///|
fn dfs_visit_out_edges(
  v : Int,
  nodes : DfsIntList,
  all_edges : DfsEdgeList,
  remaining_edges : DfsEdgeList,
  state : DfsState,
) -> DfsState where {
  proof_decrease: dfs_visit_out_edges_measure(
    nodes, all_edges, remaining_edges, state,
  ),
  proof_require: dfs_edge_list_endpoints_in(all_edges, nodes),
  proof_require: dfs_edge_list_endpoints_in(remaining_edges, nodes),
  proof_require: dfs_active_partition(state),
  proof_require: dfs_finished_edges_topological(
    all_edges,
    state.fas,
    state.finished,
  ),
  proof_ensure: result => {
    dfs_unvisited_count(nodes, result.visited) <=
    dfs_unvisited_count(nodes, state.visited)
  },
  proof_ensure: result => {
    dfs_unvisited_budget(
      nodes,
      result.visited,
      dfs_edge_list_length_model(all_edges) + 2,
    ) <=
    dfs_unvisited_budget(
      nodes,
      state.visited,
      dfs_edge_list_length_model(all_edges) + 2,
    )
  },
  proof_ensure: result => dfs_active_partition(result),
  proof_ensure: result => dfs_int_list_same(result.stack, state.stack),
  proof_ensure: result => {
    dfs_finished_edges_topological(all_edges, result.fas, result.finished)
  },
  proof_ensure: result => dfs_int_list_subset(state.fas, result.fas),
  proof_ensure: result => dfs_int_list_subset(state.finished, result.finished),
  proof_ensure: result => {
    dfs_out_edges_targets_finished(
      v,
      remaining_edges,
      result.fas,
      result.finished,
    )
  },
} {
  proof_assert 0 <=
    dfs_visit_out_edges_measure(nodes, all_edges, remaining_edges, state)
  match remaining_edges {
    NoDfsEdges => {
      proof_assert dfs_out_edges_targets_finished(
        v,
        NoDfsEdges,
        state.fas,
        state.finished,
      )
      proof_assert dfs_out_edges_targets_finished(
        v,
        remaining_edges,
        state.fas,
        state.finished,
      )
      state
    }
    MoreDfsEdge(edge, rest) =>
      if edge.v == v {
        let before = state
        let state = if dfs_int_list_contains(state.stack, edge.w) {
          let fas = MoreDfsInt(edge.id, state.fas)
          proof_assert dfs_int_list_mem(fas, edge.id)
          proof_assert dfs_int_list_subset(state.fas, fas)
          proof_assert dfs_finished_edges_topological(
            all_edges,
            fas,
            state.finished,
          )
          {
            visited: state.visited,
            stack: state.stack,
            finished: state.finished,
            fas,
          }
        } else {
          proof_assert dfs_int_list_mem(nodes, edge.w)
          proof_assert !dfs_int_list_mem(state.stack, edge.w)
          proof_assert dfs_visit_measure(nodes, all_edges, state) <
            dfs_visit_out_edges_measure(
              nodes, all_edges, remaining_edges, state,
            )
          let state = dfs_visit(edge.w, nodes, all_edges, state)
          proof_assert dfs_int_list_mem(state.finished, edge.w)
          state
        }
        proof_assert dfs_int_list_mem(state.fas, edge.id) ||
          dfs_int_list_mem(state.finished, edge.w)
        let state_after_edge = state
        proof_assert dfs_unvisited_count(nodes, state.visited) <=
          dfs_unvisited_count(nodes, before.visited)
        proof_assert dfs_unvisited_budget(
            nodes,
            state.visited,
            dfs_edge_list_length_model(all_edges) + 2,
          ) <=
          dfs_unvisited_budget(
            nodes,
            before.visited,
            dfs_edge_list_length_model(all_edges) + 2,
          )
        proof_assert dfs_edge_list_endpoints_in(rest, nodes)
        proof_assert dfs_int_list_same(state.stack, before.stack)
        proof_assert dfs_visit_out_edges_measure(nodes, all_edges, rest, state) <
          dfs_visit_out_edges_measure(nodes, all_edges, remaining_edges, before)
        let state = dfs_visit_out_edges(v, nodes, all_edges, rest, state)
        proof_assert dfs_int_list_subset(state_after_edge.fas, state.fas)
        proof_assert dfs_int_list_subset(
          state_after_edge.finished,
          state.finished,
        )
        if dfs_int_list_contains(state_after_edge.fas, edge.id) {
          proof_assert dfs_int_list_mem(state.fas, edge.id)
        } else {
          proof_assert dfs_int_list_mem(state_after_edge.finished, edge.w)
          proof_assert dfs_int_list_mem(state.finished, edge.w)
        }
        proof_assert dfs_out_edges_targets_finished(
          v,
          remaining_edges,
          state.fas,
          state.finished,
        )
        state
      } else {
        proof_assert dfs_edge_list_endpoints_in(rest, nodes)
        proof_assert dfs_visit_out_edges_measure(nodes, all_edges, rest, state) <
          dfs_visit_out_edges_measure(nodes, all_edges, remaining_edges, state)
        let state = dfs_visit_out_edges(v, nodes, all_edges, rest, state)
        proof_assert edge.v != v
        proof_assert dfs_out_edges_targets_finished(
          v,
          remaining_edges,
          state.fas,
          state.finished,
        )
        state
      }
  }
}

///|
fn dfs_int_list_contains(
  xs : DfsIntList,
  x : Int,
) -> Bool where {
  proof_decrease: xs,
  proof_ensure: result => result == dfs_int_list_mem(xs, x),
} {
  match xs {
    NoDfsInts => false
    MoreDfsInt(y, rest) => y == x || dfs_int_list_contains(rest, x)
  }
}

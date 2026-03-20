///|
pub fn order_run(g : Graph) -> Unit {
  let max_rank_value = max_rank(g)
  let down_layer_graphs = order_build_layer_graphs(
    g,
    range(1, limit=max_rank_value + 1),
    "in_edges",
  )
  let up_layer_graphs = order_build_layer_graphs(
    g,
    range(max_rank_value - 1, limit=-1, step=-1),
    "out_edges",
  )
  let mut layering = order_init_order(g)
  order_assign_order(g, layering)
  let mut best_cc = 999_999_999_999_999_999.0
  let mut best = order_copy_layering(layering)
  let mut i = 0
  let mut last_best = 0
  while last_best < 4 {
    let layer_graphs = if i % 2 == 1 {
      down_layer_graphs
    } else {
      up_layer_graphs
    }
    order_sweep_layer_graphs(layer_graphs, i % 4 >= 2)
    layering = build_layer_matrix(g)
    let cc = order_cross_count(g, layering)
    if cc < best_cc {
      last_best = 0
      best = order_copy_layering(layering)
      best_cc = cc
    }
    i = i + 1
    last_best = last_best + 1
  }
  order_assign_order(g, best)
}

///|
fn order_build_layer_graphs(
  g : Graph,
  ranks : Array[Int],
  relationship : String,
) -> Array[Graph] {
  let out : Array[Graph] = []
  for rank in ranks {
    out.push(order_build_layer_graph(g, rank, relationship))
  }
  out
}

///|
fn order_sweep_layer_graphs(
  layer_graphs : Array[Graph],
  bias_right : Bool,
) -> Unit {
  let cg = Graph::new()
  for lg in layer_graphs {
    let root = lg.graph().get_string_or("root", "")
    let sorted = order_sort_subgraph(lg, root, cg, bias_right~)
    for i = 0; i < sorted.vs.length(); i = i + 1 {
      lg.node(sorted.vs[i]).set_int("order", i)
    }
    order_add_subgraph_constraints(lg, cg, sorted.vs)
  }
}

///|
fn order_assign_order(g : Graph, layering : Array[Array[String]]) -> Unit {
  for layer in layering {
    for i = 0; i < layer.length(); i = i + 1 {
      let v = layer[i]
      if v == "" {
        continue
      }
      g.node(v).set_int("order", i)
    }
  }
}

///|
fn order_copy_layering(layering : Array[Array[String]]) -> Array[Array[String]] {
  layering.map(layer => layer.copy())
}

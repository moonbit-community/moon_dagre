///|
pub using @graphlib {
  type Attr,
  type Attrs,
  type EdgeObj,
  type Graph,
  type Point,
  type Value,
  attrs_value,
  clone_attrs,
  clone_value,
  edge_obj,
  empty_attrs,
  point,
  value_as_attrs,
  value_as_bool,
  value_as_float,
  value_as_int,
  value_as_string,
  value_bool,
  value_float,
  value_int,
  value_null,
  value_string,
}

///|
pub fn new_graph(
  directed? : Bool = true,
  multigraph? : Bool = false,
  compound? : Bool = false,
) -> Graph {
  Graph::new(directed~, multigraph~, compound~)
}

///|
pub fn layout(g : Graph, debug_timing? : Bool = false) -> Graph {
  @layout.run(g, debug_timing~)
}

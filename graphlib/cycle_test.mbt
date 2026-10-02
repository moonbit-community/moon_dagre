///|
priv struct DefaultLabelCounter {
  mut value : Int
}

///|
test "panic Attrs::set_value rejects direct cycles" {
  let attrs = empty_attrs()
  attrs.set_value("self", attrs_value(attrs))
}

///|
test "panic Attrs::set_value rejects indirect cycles" {
  let parent = empty_attrs()
  let child = empty_attrs()
  parent.set_value("child", attrs_value(child))
  child.set_value("parent", attrs_value(parent))
}

///|
test "Attrs accepts acyclic nested values" {
  let parent = empty_attrs()
  let child = empty_attrs()
  child.set_int("value", 42)
  parent.set_value("child", attrs_value(child))
  let nested = value_as_attrs(parent.get_value("child"))
  assert_eq(nested.unwrap().get_int("value"), Some(42))
}

///|
test "panic Graph::set_parent rejects self-parenting" {
  let graph = Graph::new(compound=true)
  graph.set_parent("a", parent="a")
}

///|
test "panic Graph::set_parent rejects ancestor cycles" {
  let graph = Graph::new(compound=true)
  graph.set_parent("a", parent="b")
  graph.set_parent("b", parent="c")
  graph.set_parent("c", parent="a")
}

///|
test "Graph::set_default_edge_label stores an independent template" {
  let graph = Graph::new()
  let counter : DefaultLabelCounter = { value: 0, }
  graph.set_default_edge_label(() => {
    counter.value = counter.value + 1
    let attrs = empty_attrs()
    attrs.set_int("weight", counter.value)
    attrs_value(attrs)
  })
  assert_eq(counter.value, 1)
  graph.set_edge("a", "b")
  graph.set_edge("b", "c")
  assert_eq(counter.value, 1)
  let first = value_as_attrs(graph.edge("a", "b")).unwrap()
  let second = value_as_attrs(graph.edge("b", "c")).unwrap()
  first.set_int("weight", 99)
  assert_eq(second.get_int("weight"), Some(1))
}

///|
test "Graph::set_default_edge_label does not retain a capturing closure" {
  let graph = Graph::new()
  graph.set_default_edge_label(() => {
    ignore(graph.node_count())
    value_int(1)
  })
  graph.set_edge("a", "b")
  assert_eq(value_as_int(graph.edge("a", "b")), Some(1))
}

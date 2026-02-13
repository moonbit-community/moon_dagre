///|
// Upstream: dagre-reference/test/data/list-test.js
test "list dequeue empty" {
  let list : List[String] = List::new()
  inspect(list.dequeue(), content="None")
}

///|
test "list dequeue follows FIFO" {
  let list : List[String] = List::new()
  list.enqueue("a")
  list.enqueue("b")
  assert_eq(list.dequeue(), Some("a"))
  assert_eq(list.dequeue(), Some("b"))
}

///|
test "list re-enqueue moves entry" {
  let list : List[String] = List::new()
  list.enqueue("a")
  list.enqueue("b")
  list.enqueue("a")
  assert_eq(list.dequeue(), Some("b"))
  assert_eq(list.dequeue(), Some("a"))
}

///|
test "list to_string" {
  let list : List[Int] = List::new()
  list.enqueue(1)
  list.enqueue(2)
  inspect(list.to_string(), content="[1, 2]")
}

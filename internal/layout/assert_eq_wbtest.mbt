///|
#callsite(autofill(loc))
fn[T : Eq] assert_eq(actual : T, expected : T, loc~ : SourceLoc) -> Unit raise {
  if actual != expected {
    fail("assert_eq failed", loc~)
  }
}

///|
fn order_bary_entry(
  v : String,
  barycenter? : Double? = None,
  weight? : Double? = None,
) -> OrderBarycenterEntry {
  { v, barycenter, weight }
}

///|
fn order_entry(
  vs : Array[String],
  i : Int,
  barycenter? : Double? = None,
  weight? : Double? = None,
) -> OrderEntry {
  { vs, i, barycenter, weight }
}

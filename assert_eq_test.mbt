///|
#callsite(autofill(loc))
fn[T : Eq] assert_eq(actual : T, expected : T, loc~ : SourceLoc) -> Unit raise {
  if actual != expected {
    fail("assert_eq failed", loc~)
  }
}

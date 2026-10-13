///|
priv struct OrderBarycenterEntry {
  v : String
  mut barycenter : Double?
  mut weight : Double?
}

///|
priv struct OrderEntry {
  mut vs : Array[String]
  i : Int32
  barycenter : Double?
  weight : Double?
}

///|
priv struct OrderResult {
  mut vs : Array[String]
  mut barycenter : Double?
  mut weight : Double?
}

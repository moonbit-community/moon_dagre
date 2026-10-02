///|
// Upstream: dagre-reference/test/version-test.js
test "version matches pinned upstream" {
  inspect(@moon_dagre.version(), content="0.8.5")
}

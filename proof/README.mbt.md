# Milky2018/moon_dagre/proof

This proof-only package verifies selected properties of the coordinate-transform
planning code used by the runtime `moon_dagre` package.

## Connection To Runtime Code

The root package implementation of `coordinate_adjust` and `coordinate_undo`
calls the shared `Milky2018/moon_dagre/coordinate_transform` package to choose
its transform plans.

The actual exported functions `coordinate_adjust_plan` and
`coordinate_undo_plan` are proved in the `coordinate_transform` package. This
package proves the algebraic effect of the selected plans.

## Verified Properties

The proof establishes two layers of facts:

- Plan selection: the shared runtime functions select the expected adjust/undo
  plans for `LR`, `BT`, and `RL`.
- Plan algebra: applying those selected plans to an abstract coordinate state
  `(x, y, width, height)` produces the expected final mapping.

The non-trivial rank-direction results are:

- `LR`: adjust followed by undo produces `(y, x, width, height)`.
- `BT`: adjust followed by undo produces `(x, -y, width, height)`.
- `RL`: adjust followed by undo produces `(-y, x, width, height)`.

These properties verify that the production-selected adjust/undo plan has the
expected coordinate mapping and preserves `width` and `height` after the full
pipeline.

## Limits

The proof does not yet verify the mutable `Graph`, `Attrs`, or edge-point update
loops in the root package. It verifies the shared plan selection and the
algebraic coordinate effect of the selected plans.

## Run

```bash
moon prove coordinate_transform
moon prove proof
```

# Milky2018/moon_dagre/coordinate_transform

This package contains the shared coordinate-transform planning code used by the
runtime `moon_dagre` package and by MoonBit formal verification.

## Verified Code

The runtime implementation calls:

- `coordinate_adjust_plan`
- `coordinate_undo_plan`

Those same functions are imported by the proof-only `proof` package. The proofs
are therefore tied to code that is on the production execution path, rather than
to a separate copy of the plan logic.

## Verified Properties

The proof models the algebraic effect of each plan on an abstract coordinate
state `(x, y, width, height)` and proves the non-trivial rank-direction cases:

- `LR`: adjust followed by undo produces `(y, x, width, height)`.
- `BT`: adjust followed by undo produces `(x, -y, width, height)`.
- `RL`: adjust followed by undo produces `(-y, x, width, height)`.

These properties verify that the production-selected adjust/undo plan has the
expected coordinate mapping and preserves `width` and `height` after the full
pipeline.

## Limits

The proof does not yet verify the mutable `Graph`, `Attrs`, or edge-point update
loops in the root package. It verifies the shared plan selection and its
algebraic coordinate effect.

## Run

```bash
moon prove coordinate_transform
moon prove proof
```

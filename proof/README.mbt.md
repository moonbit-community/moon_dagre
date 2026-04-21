# Milky2018/moon_dagre/proof

This package contains proof-only models for selected properties of the
`moon_dagre` layout engine.

## Scope

The current proof work focuses on the coordinate-system transforms used by
`coordinate_adjust` and `coordinate_undo`.

Instead of proving the mutable `Graph` implementation directly, this package
uses a small integer model `(x, y, width, height)` and proves the effect of the
same transform sequence on that abstract state.

## Verified Properties

The package proves the non-trivial rank-direction cases:

- `LR`: applying adjust, then undo, produces `(y, x, width, height)`.
- `BT`: applying adjust, then undo, produces `(x, -y, width, height)`.
- `RL`: applying adjust, then undo, produces `(-y, x, width, height)`.

These statements mean:

- the final coordinate mapping is mathematically consistent with the intended
  rank-direction transform;
- width and height are preserved after the full adjust/undo pipeline;
- the proof covers the algebraic effect of the transformation, not just a set
  of examples.

## Limits

This package does not yet prove:

- the imperative mutation over `Graph`, `Attrs`, or edge point arrays;
- that every call site in the runtime package uses the model in exactly the
  same way;
- the trivial `TB` case, whose effect is the identity transform.

In other words, the proof currently establishes the transform law, not full
end-to-end correctness of the mutable layout implementation.

## Run

```bash
moon prove proof
```

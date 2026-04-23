///|
pub(all) enum RankDir {
  TB
  BT
  LR
  RL
}

///|
pub(all) enum CoordinateAdjustPlan {
  AdjustIdentity
  AdjustSwapWidthHeight
}

///|
pub(all) enum CoordinateUndoPlan {
  UndoIdentity
  UndoReverseY
  UndoSwapXYAndSwapWidthHeight
  UndoReverseYSwapXYAndSwapWidthHeight
}

///|
#proof_pure
pub fn coordinate_adjust_plan(rank_dir : RankDir) -> CoordinateAdjustPlan {
  match rank_dir {
    RankDir::LR | RankDir::RL => CoordinateAdjustPlan::AdjustSwapWidthHeight
    RankDir::TB | RankDir::BT => CoordinateAdjustPlan::AdjustIdentity
  }
}

///|
#proof_pure
pub fn coordinate_undo_plan(rank_dir : RankDir) -> CoordinateUndoPlan {
  match rank_dir {
    RankDir::TB => CoordinateUndoPlan::UndoIdentity
    RankDir::BT => CoordinateUndoPlan::UndoReverseY
    RankDir::LR => CoordinateUndoPlan::UndoSwapXYAndSwapWidthHeight
    RankDir::RL => CoordinateUndoPlan::UndoReverseYSwapXYAndSwapWidthHeight
  }
}

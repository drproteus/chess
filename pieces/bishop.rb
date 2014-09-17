require_relative 'sliding_piece'

class Bishop < SlidingPiece
  def move_dirs
    [DELTAS[:nw], DELTAS[:ne], DELTAS[:sw], DELTAS[:se]]
  end

  def to_s
    @color == :b ? "\u{265d}" : "\u{2657}"
  end
end
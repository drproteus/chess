require_relative 'sliding_piece.rb'

class Rook < SlidingPiece
  def move_dirs
    [DELTAS[:n], DELTAS[:e], DELTAS[:s], DELTAS[:w]]
  end

  def to_s
    @color == :b ? "\u{265c}" : "\u{2656}"
  end
end
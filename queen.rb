require_relative 'sliding_piece'

class Queen < SlidingPiece
  def move_dirs
    DELTAS.values
  end

  def to_s
    @color == :b ? "\u{265b}" : "\u{2655}"
  end
end
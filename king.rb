require_relative 'stepping_piece'

class King < SteppingPiece
  def move_dirs
    DELTAS.values
  end

  def to_s
    @color == :b ? "\u{265a}" : "\u{2654}"
  end
end
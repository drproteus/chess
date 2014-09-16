require_relative 'stepping_piece'

class Knight < SteppingPiece
  def move_dirs
    [
      [DELTAS[:n]] * 2 + [DELTAS[:e]],
      [DELTAS[:n]] * 2 + [DELTAS[:w]],
      [DELTAS[:s]] * 2 + [DELTAS[:e]],
      [DELTAS[:s]] * 2 + [DELTAS[:w]],
      [DELTAS[:e]] * 2 + [DELTAS[:n]],
      [DELTAS[:w]] * 2 + [DELTAS[:n]],
      [DELTAS[:e]] * 2 + [DELTAS[:s]],
      [DELTAS[:w]] * 2 + [DELTAS[:s]],
    ].map { |vec| vector_sum(vec) }
  end

  def to_s
    @color == :b ? "\u{265e}" : "\u{2658}"
  end
end
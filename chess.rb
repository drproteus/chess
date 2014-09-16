class Piece
  # row, col
  DELTAS = { nw: [1, -1],  n: [1, 0],  ne: [1, 1],
                  w: [0, -1],               e: [0, 1],
                 sw: [-1, -1], s: [-1, 0], se: [-1, 1] }

  def initialize(pos, board)
    @pos = pos
    @board = board
  end

  def moves

  end
end

class SlidingPiece < Piece

end

class SteppingPiece < Piece

end

class Pawn < Piece

end

class Bishop < SlidingPiece

  def move_dirs
    @move_dirs = [DELTAS[:nw], DELTAS[:ne], DELTAS[:sw], DELTAS[:se]]
  end
end

class Rook < SlidingPiece
  def move_dirs
    @move_dirs = [DELTAS[:n], DELTAS[:e], DELTAS[:s], DELTAS[:w]]
  end
end

class Queen < SlidingPiece
  def move_dirs
    @move_dirs = DELTAS.values
  end
end

class Knight < SteppingPiece

end

class King < SteppingPiece

end
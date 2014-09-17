require_relative 'piece'

class SteppingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      next_move = vector_sum([pos, dir])
      moves << next_move
    end

    moves
  end
end
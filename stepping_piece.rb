require_relative 'piece'

class SteppingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      next_move = vector_sum([pos, dir])
      next unless move_within_boundaries?(next_move)
      next if !@board[next_move].nil? && @board[next_move].color == self.color
      moves << next_move
    end

    moves
  end
end
require_relative 'piece'

class SlidingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      current_pos = @pos
      loop do
        next_move = vector_sum([current_pos, dir])
        moves << next_move
        break unless move_within_boundaries?(next_move) && @board[next_move].nil?
        current_pos = next_move
      end
    end

    moves
  end
end
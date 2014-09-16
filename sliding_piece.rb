require_relative 'piece'

class SlidingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      current_pos = @pos
      loop do
        next_move = vector_sum([current_pos, dir])
        break unless move_within_boundaries?(next_move)
        break if !@board[next_move].nil? && @board[next_move].color == self.color
        moves << next_move
        break unless @board[next_move].nil? #change .empty? to whatever call

        current_pos = next_move
      end
    end

    moves
  end
end
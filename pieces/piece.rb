require_relative 'vector_sum'

class Piece
  attr_reader :color, :pos, :prev_pos, :last_turn_moved

  # row, col
  DELTAS = { nw: [-1, -1],  n: [-1, 0], ne: [-1, 1],
              w: [0, -1],                e: [0, 1],
             sw: [1, -1],   s: [1, 0],  se: [1, 1] }

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
    @prev_pos = pos
    @last_turn_moved = nil
  end

  def move_to(target)
    @last_turn_moved = @board.move_count
    @prev_pos = self.pos
    @board[self.pos], @board[target] = nil, self
    @pos = target
  end

  def move_within_boundaries?(pos)
    row, col = pos
    row.between?(0, @board.height - 1) && col.between?(0, @board.width - 1)
  end

  def valid_moves
    moves.select { |move| valid_move?(move) }
  end

  def valid_move?(target)
    duped_board = @board.dup
    duped_board.move!(@pos, target)
    return false if duped_board.in_check?(self.color)
    return false unless move_within_boundaries?(target)
    return false if !@board[target].nil? && @board[target].color == self.color

    true
  end
end
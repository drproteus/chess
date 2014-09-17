require_relative 'stepping_piece'

class King < SteppingPiece
  def move_dirs
    DELTAS.values
  end

  def to_s
    @color == :b ? "\u{265a}" : "\u{2654}"
  end

  def moves
    moves = super
    if self.last_turn_moved.nil?
      moves << vector_sum([[0, 2], self.pos])
      moves << vector_sum([[0, -2], self.pos])
    end

    moves
  end

  def move_to(target)
    if target == vector_sum([[0, 2], self.pos])
      castle_right(target) if can_castle_right?(target)
    elsif target == vector_sum([[0, -2], self.pos])
      castle_left(target) if can_castle_left?(target)
    end
    super
  end

  private

  def can_castle_left?(target)
    row, col = target
    3.times { |i| return false unless @board[[row, col + (i - 1)]].nil? }
    rook_pos = [row, col - 2]
    return false unless @board[rook_pos].class == Rook
    return false unless @board[rook_pos].last_turn_moved.nil?

    true
  end

  def can_castle_right?(target)
    row, col = target
    2.times { |i| return false unless @board[[row, col - i]].nil? }
    rook_pos = [row, col + 1]
    return false unless @board[rook_pos].class == Rook
    return false unless @board[rook_pos].last_turn_moved.nil?

    true
  end

  def castle_left(target)
    row, col = target
    rook_pos, new_rook_pos = [row, col - 2], [row, col + 1]
    @board[rook_pos].move_to(new_rook_pos)
  end

  def castle_right(target)
    row, col = target
    rook_pos, new_rook_pos = [row, col + 1], [row, col - 1]
    @board[rook_pos].move_to(new_rook_pos)
  end

end
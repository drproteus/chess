require_relative 'piece'

class Pawn < Piece
  def move_dirs
    case @color
    when :w
      [DELTAS[:n], DELTAS[:ne], DELTAS[:nw]]
    when :b
      [DELTAS[:s], DELTAS[:se], DELTAS[:sw]]
    end
  end

  def moves
    moves = []
    dirs = move_dirs

    advance = vector_sum([@pos, dirs[0]])
    if @board[advance].nil?
      moves << advance
      unless moved?
        advance = vector_sum([advance, dirs[0]])
        moves << advance if @board[advance].nil?
      end
    end

    2.times do |i|
      advance = vector_sum([@pos, dirs[i + 1]])
      unless @board[advance].nil? || @board[advance].color == self.color
        moves << advance
      end
    end

    moves.select { |move| move_within_boundaries?(move) }
  end

  def to_s
    @color == :b ? "\u{265f}" : "\u{2659}"
  end

  def moved?
    case @color
    when :w
      @pos.first != @board.height - 2
    when :b
      @pos.first != 1
    end
  end

end
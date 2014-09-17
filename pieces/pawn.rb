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

  def move_to(target)
    if en_passant?(target)
      case self.color
      when :b
        @board[vector_sum([target, DELTAS[:n]])] = nil
      when :w
        @board[vector_sum([target, DELTAS[:s]])] = nil
      end
    end
    super
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
      moves << advance if valid_capture?(advance) || en_passant?(advance)
    end

    moves.select { |move| move_within_boundaries?(move) }
  end

  def valid_capture?(advance)
    !@board[advance].nil? && @board[advance].color != self.color
  end

  def en_passant?(advance)
    case self.color
    when :b
      pawn_pos = vector_sum([advance, DELTAS[:n]])
      return false if @board[pawn_pos].class != Pawn
      return false if @board[pawn_pos].nil? || @board[pawn_pos].prev_pos[0] != 6
    when :w
      pawn_pos = vector_sum([advance, DELTAS[:s]])
      return false if @board[pawn_pos].class != Pawn
      return false if @board[pawn_pos].nil? || @board[pawn_pos].prev_pos[0] != 1
    end
    @board[pawn_pos].last_turn_moved == @board.move_count - 1
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
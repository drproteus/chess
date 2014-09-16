def vector_sum(vectors)
  result = [0,0]
  vectors.each do |vec|
    result[0] += vec[0]
    result[1] += vec[1]
  end
  result
end

class Piece
  # row, col
  DELTAS = { nw: [1, -1],  n: [1, 0],  ne: [1, 1],
                  w: [0, -1],               e: [0, 1],
                 sw: [-1, -1], s: [-1, 0], se: [-1, 1] }

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def moves

  end
end

class SlidingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      current_pos = pos
      loop do
        next_move = vector_sum([current_pos, dir])

        break if @board[next_move].color == self.color
        moves << next_move
        break unless @board[next_move].empty? #change .empty? to whatever call

        current_pos = next_move
      end
    end

    moves
  end
end

class SteppingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      next_move = vector_sum([pos, dir])
      next if @board[next_move].color == self.color
      moves << next_move if @board[next_move].empty? #change empty
    end

    moves
  end
end

class Pawn < Piece
  def initialize(color)
    super
    @moved = false
  end

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
    next_move = vector_sum([@pos, dirs.first])
    moves << next_move if @board[next_move].empty?
    moves << vector_sum([next_move, dirs.first]) unless @moved
    next_move = vector_sum([@pos, dirs[1]])
    unless @board[next_move].empty? || @board[next_move].color == self.color
      moves << next_move
    end
    next_move = vector_sum([@pos, dirs.last])
    unless @board[next_move].empty? || @board[next_move].color == self.color
      moves << next_move
    end

    moves
  end
end

class Bishop < SlidingPiece

  def move_dirs
    [DELTAS[:nw], DELTAS[:ne], DELTAS[:sw], DELTAS[:se]]
  end
end

class Rook < SlidingPiece
  def move_dirs
    [DELTAS[:n], DELTAS[:e], DELTAS[:s], DELTAS[:w]]
  end
end

class Queen < SlidingPiece
  def move_dirs
    DELTAS.values
  end
end

class Knight < SteppingPiece
  def move_dirs
    [
      [DELTAS[:n]] * 3 + [DELTAS[:e]],
      [DELTAS[:n]] * 3 + [DELTAS[:w]],
      [DELTAS[:s]] * 3 + [DELTAS[:e]],
      [DELTAS[:s]] * 3 + [DELTAS[:w]],
      [DELTAS[:e]] * 3 + [DELTAS[:n]],
      [DELTAS[:w]] * 3 + [DELTAS[:n]],
      [DELTAS[:e]] * 3 + [DELTAS[:s]],
      [DELTAS[:w]] * 3 + [DELTAS[:s]],
    ].map { |vec| vector_sum(vec) }
  end
end

class King < SteppingPiece
  def move_dirs
    DELTAS.values
  end
end
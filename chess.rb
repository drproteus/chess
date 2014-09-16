# encoding: utf-8

def vector_sum(vectors)
  result = [0,0]
  vectors.each do |vec|
    result[0] += vec[0]
    result[1] += vec[1]
  end
  result
end

class Piece
  attr_reader :color
  attr_accessor :pos
  # row, col
  DELTAS = { nw: [-1, -1],  n: [-1, 0],  ne: [-1, 1],
                  w: [0, -1],               e: [0, 1],
                 sw: [1, -1], s: [1, 0], se: [1, 1] }

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def move_within_boundaries?(pos)
    row, col = pos
    row.between?(0, @board.height) && col.between?(0, @board.width)
  end

  def valid_moves
    moves.select { |move| valid_move?(move) }
  end

  def valid_move?(target)
    duped_board = @board.dup
    duped_board.move!(@pos, target)
    !duped_board.in_check?(self.color)
  end
end

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

class SteppingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      next_move = vector_sum([pos, dir])
      next unless move_within_boundaries?(next_move)
      next if !@board[next_move].nil? && @board[next_move].color == self.color
      moves << next_move if @board[next_move].nil? #change empty
    end

    moves
  end
end

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

class Bishop < SlidingPiece
  def move_dirs
    [DELTAS[:nw], DELTAS[:ne], DELTAS[:sw], DELTAS[:se]]
  end

  def to_s
    @color == :b ? "\u{265d}" : "\u{2657}"
  end
end

class Rook < SlidingPiece
  def move_dirs
    [DELTAS[:n], DELTAS[:e], DELTAS[:s], DELTAS[:w]]
  end

  def to_s
    @color == :b ? "\u{265c}" : "\u{2656}"
  end
end

class Queen < SlidingPiece
  def move_dirs
    DELTAS.values
  end

  def to_s
    @color == :b ? "\u{265b}" : "\u{2655}"
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

  def to_s
    @color == :b ? "\u{265e}" : "\u{2658}"
  end
end

class King < SteppingPiece
  def move_dirs
    DELTAS.values
  end

  def to_s
    @color == :b ? "\u{265a}" : "\u{2654}"
  end
end

class Board
  def initialize
    @board = Array.new(8) { Array.new(8) }
    place_pieces
  end

  def height
    @board.count
  end

  def width
    @board[0].count
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @board[row][col] = value
  end

  def place_pieces
    place_piece_row(0, :b)
    place_pawn_row(1, :b)
    place_pawn_row(6, :w)
    place_piece_row(7, :w)
  end

  def place_pawn_row(row, color)
    @board[row].each_with_index do |spot, i|
       @board[row][i] = Pawn.new([row, i], self, color)
     end

     nil
  end

  def place_piece_row(row, color)
    starting_row = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    @board[row].each_with_index do |spot, i|
      @board[row][i] = starting_row[i].new([row, i], self, color)
    end

    nil
  end

  def display
    puts '  ' + ('a'..'h').to_a.join(' ')
    @board.each_with_index do |row, index|
      print "#{8 - index} "
      row.each do |piece|
        print (piece.nil? ? ' ' : piece.to_s) + ' '
      end
      print "#{8 - index}"
      puts
    end
    puts '  ' + ('a'..'h').to_a.join(' ')

    nil
  end

  def find_king(color)
    @board.flatten.each do |piece|
      if piece.class == King && piece.color == color
        return piece.pos
      end
    end

    nil
  end

  def in_check?(color)
    king_pos = find_king(color)
    @board.flatten.each do |piece|
      next if piece.color == color
      return true if piece.moves.include?(king_pos)
    end

    false
  end

  def move!(start, end_pos)
    # changes piece.pos to end_pos
    piece.pos = end_pos

    # changes Board positions
    self[start], self[end_pos] = nil, piece

    nil
  end

  def move(start, end_pos)
    # finds piece at start position
    piece = self[start]
    if piece.nil?
      raise "No piece at start position."
    end

    # checks piece.moves for end_pos
    unless piece.moves.include?(end_pos)
      raise "Can't move to that position."
    end

    unless piece.valid_moves.include?(end_pos)
      raise "Move will leave you in check."
    end

    piece.pos = end_pos
    self[start], self[end_pos] = nil, piece

    nil
  end

  def checkmate(color)
    pieces = @board.flatten.compact.select { |piece| piece.color == color }
    pieces.all? { |piece| piece.valid_moves.empty? }
  end

  def dup
    duped_board = Array.new(8) { Array.new(8) }
    @board.each_with_index do |row, row_index|
      row.each_with_index do |piece, col_index|
        next if piece.nil?
        pos = [row_index, col_index]
        color = piece.color
        duped_board[row_index][col_index] = piece.class.new(pos, duped_board, color)
      end
    end

    duped_board
  end

end

class Game
  def initialize(white, black)
    @board = Board.new
    @player1 = white
    @player2 = black
  end



end

class HumanPlayer
  def play_turn
    move_string = gets.chomp
    start, target = move_string.scan(/\D\d/)
    [parse(start), parse(target)]

  end

  def parse(pos_string)
    letters, numbers = ('a'..'h').to_a, (1..8).to_a.reverse

    [letters.index(pos_string[0]), numbers.index(pos_string[1].to_i)]
  end
end
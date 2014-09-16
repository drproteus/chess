require_relative 'king'
require_relative 'knight'
require_relative 'queen'
require_relative 'pawn'
require_relative 'bishop'
require_relative 'rook'

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
       self[[row, i]] = Pawn.new([row, i], self, color)
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
    puts ''
    puts '    ' + ('a'..'h').to_a.join(' ')
    @board.each_with_index do |row, index|
      print "  #{8 - index} "
      row.each do |piece|
        print (piece.nil? ? ' ' : piece.to_s) + ' '
      end
      print "#{8 - index}"
      puts
    end
    puts '    ' + ('a'..'h').to_a.join(' ')
    puts ' '

    nil
  end

  def pieces
    @board.flatten.compact
  end

  def find_king_pos(color)
    self.pieces.each do |piece|
      if piece.class == King && piece.color == color
        return piece.pos
      end
    end

    nil
  end

  def in_check?(color)
    king_pos = find_king_pos(color)
    self.pieces.each do |piece|
      next if piece.color == color
      return true if piece.moves.include?(king_pos)
    end

    false
  end

  def pos_on_board?(pos)
    row, col = pos
    row.between?(0, height - 1) && col.between?(0, width - 1)
  end

  def move!(start, end_pos)
    return unless pos_on_board?(start) && pos_on_board?(end_pos)
    piece = self[start]
    piece.pos = end_pos
    self[start], self[end_pos] = nil, piece

    nil
  end

  def move(start, end_pos)
    piece = self[start]
    if piece.nil?
      raise "No piece at start position."
    end

    unless piece.moves.include?(end_pos)
      raise "Can't move to that position."
    end

    unless piece.valid_moves.include?(end_pos)
      raise "Move will leave you in check."
    end

    move!(start, end_pos)
  end

  def checkmate?(color)
    pieces = self.pieces.select { |piece| piece.color == color }
    pieces.all? { |piece| piece.valid_moves.empty? }
  end

  def dup
    duped_board = Board.new #Array.new(8) { Array.new(8) }
    @board.each_with_index do |row, row_index|
      row.each_with_index do |piece, col_index|
        pos = [row_index, col_index]
        if piece.nil?
          duped_board[pos] = nil
        else
          duped_board[pos] = piece.class.new(pos, duped_board, piece.color)
        end
      end
    end

    duped_board
  end

end
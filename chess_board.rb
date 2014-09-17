require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/queen'
require_relative 'pieces/pawn'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'

class Board
  attr_reader :move_count

  def initialize
    @board = Array.new(8) { Array.new(8) }
    @move_count = 0
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
    piece.move_to(end_pos)
    # self[start], self[end_pos] = nil, piece

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

    outcome = outcome_string(start, end_pos)

    move!(start, end_pos)
    @move_count += 1
    outcome
  end

  def outcome_string(start, target)
    piece = self[start]
    target_piece = self[target]
    outcome = nil
    unless target_piece.nil?
      outcome = "#{piece.class}(#{piece.color}) took #{target_piece.class}(#{target_piece.color})"
    end

    if piece.class == Pawn && piece.en_passant?(target)
      target_piece_color = (piece.color == :w ? :b : :w)
      outcome = "#{piece.class}(#{piece.color}) took #{piece.class}(#{target_piece_color}) en passant"
    end

    outcome
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
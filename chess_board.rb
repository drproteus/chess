require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/queen'
require_relative 'pieces/pawn'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'
require 'colorize'

class Board
  attr_reader :captured_pieces
  attr_accessor :moves, :fifty_move_rule_counter, :move_count, :position_history

  def initialize(custom_game = false)
    @board = Array.new(8) { Array.new(8) }
    @move_count = 0
    @captured_pieces = { :w => [], :b => [] }
    place_pieces unless custom_game
    @moves = []
    @position_history = []
    @fifty_move_rule_counter = 0
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


  def display
    puts ''
    puts '     ' + ('a'..'h').to_a.join('  ') + '      Turn Log'
    @board.each_with_index do |row, row_index|
      print "  #{8 - row_index} "
      row.each_with_index do |piece, col_index|
        string = ' ' + (piece.nil? ? ' ' : piece.to_s) + ' '
        if (row_index + col_index).odd?
          print string.colorize(background: :red)
        else
          print string
        end
      end
      print " #{8 - row_index}"
      move_log = @moves.last(8)
      unless move_log.empty? || move_log[row_index].nil?
        print "     #{move_log[row_index].join('  ')}" if row_index.between?(0, 7)
      else
        print "              "
      end
      print '   '
      if row_index == 0
        print @captured_pieces[:w].map(&:to_s).join(' ')
      elsif row_index == 1
        print @captured_pieces[:b].map(&:to_s).join(' ')
      end

      puts
    end
    puts '     ' + ('a'..'h').to_a.join('  ')
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
    @fifty_move_rule_counter += 1
    @fifty_move_rule_counter = 0 unless outcome.nil?
    @position_history << self.dup
    outcome
  end

  def checkmate?(color)
    player_pieces = self.pieces.select { |piece| piece.color == color }
    player_pieces.all? { |piece| piece.valid_moves.empty? }
  end

  def ==(other_board)
    8.times do |row_index|
      8.times do |col_index|
        other_piece = other_board[[row_index, col_index]]
        next if other_piece.nil?
        this_piece = self[[row_index, col_index]]
        return false if other_piece.class != this_piece.class
        return false if other_piece.color != this_piece.color
      end
    end
    true
  end

  def dup
    duped_board = Board.new
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

  def draw?
    stalemate? || threefold_repetition? || fifty_move_rule?
  end

  def stalemate?
    curr_player = move_count.even? ? :w : :b

    return false if in_check?(curr_player)
    player_pieces = pieces.select{ |piece| piece.color == curr_player }
    player_pieces.all? { |piece| piece.valid_moves.empty? }
  end

  def threefold_repetition?
    @position_history.each do |position|
      return true if @position_history.count(position) == 3
    end
    false
  end

  def fifty_move_rule?
    @fifty_move_rule_counter == 50
  end

  def pawn_promote(pawn, new_class)
    pos, color = pawn.pos, pawn.color
    self[pos] = new_class.new(pos, self, color)
  end

  private

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

  def place_pieces
    place_piece_row(0, :b)
    place_pawn_row(1, :b)
    place_pawn_row(6, :w)
    place_piece_row(7, :w)
  end

  def place_piece(piece, pos, color)
    self[pos] = piece.new(pos, self, color)
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

end

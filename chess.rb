#!/usr/bin/env ruby
LOGO = %q{      ___          ___          ___          ___          ___
     /\  \        /\__\        /\  \        /\  \        /\  \
    /::\  \      /:/  /       /::\  \      /::\  \      /::\  \
   /:/\:\  \    /:/__/       /:/\ \  \    /:/\ \  \    /:/\:\  \
  /:/  \:\  \  /::\  \ ___  _\:\~\ \  \  _\:\~\ \  \  /::\~\:\  \
 /:/__/ \:\__\/:/\:\  /\__\/\ \:\ \ \__\/\ \:\ \ \__\/:/\:\ \:\__\
 \:\  \  \/__/\/__\:\/:/  /\:\ \:\ \/__/\:\ \:\ \/__/\/_|::\/:/  /
  \:\  \           \::/  /  \:\ \:\__\   \:\ \:\__\     |:|::/  /
   \:\  \          /:/  /    \:\/:/  /    \:\/:/  /     |:|\/__/
    \:\__\        /:/  /      \::/  /      \::/  /      |:|  |
     \/__/        \/__/        \/__/        \/__/        \|__|    }
require_relative 'chess_board'
require_relative 'human_player'

class Game
  def initialize(white, black)
    @player1 = white
    @player2 = black
    @curr_player = @player1
    @piece_hash = { "King" => King, "Queen" => Queen, "Knight" => Knight,
                    "Rook" => Rook, "Bishop" => Bishop, "Pawn" => Pawn }
  end

  def play
    @move_outcome = nil
    @start_time = Time.now
    @moves = []

    until @board.checkmate?(:w) || @board.checkmate?(:b)
      system('clear')
      puts LOGO
      @board.display(@moves.last(8))



      turn

      @curr_player = (@curr_player == @player1 ? @player2 : @player1)
    end

    game_over
  end

  def main_menu
    system('clear')
    puts LOGO.colorize(:blink)
    puts "Type 'play' to start a standard game of chess."
    puts "Type 'custom' to create a custom board."
    entry = gets.chomp
    if entry == 'play'
      @board = Board.new
    elsif entry == 'custom'
      @board = Board.new(true)

      loop do
        system('clear')
        @board.display

        puts "Enter custom piece to place in this format:"
        puts "color, piece type, position (e.g. 'b queen b3')"
        puts "Type 'q' to stop placing pieces."

        entry = gets.chomp
        break if entry[0] == 'q'
        piece = parse_piece_string(entry)
        @board[piece.pos] = piece
      end
    end
    self.play
  end

  private

  def turn
    begin
      puts @move_outcome unless @move_outcome.nil?
      puts "Check." if @board.in_check?(@curr_player)
      puts "#{@curr_player.name}'s turn."
      start, target = @curr_player.play_turn
      if start.nil? || target.nil?
        raise "Invalid input."
      end
      @move_outcome = make_move(@curr_player.color, parse(start), parse(target))
    rescue RuntimeError => e
      puts e.message
      puts "Please select valid move."
      retry
    end
    if @board[parse(target)].class == Pawn && @board[parse(target)].can_promote?
      pawn_promote(target)
    end
    @moves << [start, target, @curr_player.color]
  end

  def make_move(color, start, target)
    raise "Empty start position" if @board[start].nil?
    raise "Incorrect color piece" if @board[start].color != color
    move_outcome = @board.move(start, target)
  end

  def game_over
    system('clear')
    @board.display
    winner = @board.checkmate?(:w) ? @player2.name : @player1.name
    puts "CHECKMATE. #{winner} wins."
    puts "Game lasted for #{@board.move_count / 2} turns."
    puts "Game time: #{Time.now - @start_time}s"
  end

  def parse(pos_string)
    letters, numbers = ('a'..'h').to_a, (1..8).to_a.reverse

    [numbers.index(pos_string[1].to_i), letters.index(pos_string[0])]
  end

  def promote_pawn(target)
    loop do
      puts "Pawn can be promoted. Input class for new piece."
      new_class = gets.chomp.capitalize
      if @piece_hash.has_key?(new_class)
        @board.pawn_promote(@board[parse(target)], @piece_hash[new_class])
        break
      end
    end
    nil
  end

  def parse_piece_string(input_string)
    color_string, piece_string, pos_string = input_string.split(' ')
    color = color_string.to_sym
    piece_class = @piece_hash[piece_string.capitalize]
    pos = parse(pos_string)
    piece_class.new(pos, @board, color)
  end

end

if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new(:w, 'Foo')
  player2 = HumanPlayer.new(:b, 'Bar')
  game = Game.new(player1, player2)
  game.main_menu
end
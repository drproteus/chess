#!/usr/bin/env ruby
require_relative 'chess_board'
require_relative 'human_player'
require 'yaml'

LOGO = %q{
      ___          ___          ___          ___          ___
     /\  \        /\__\        /\  \        /\  \        /\  \
    /::\  \      /:/  /       /::\  \      /::\  \      /::\  \
   /:/\:\  \    /:/__/       /:/\ \  \    /:/\ \  \    /:/\:\  \
  /:/  \:\  \  /::\  \ ___  _\:\~\ \  \  _\:\~\ \  \  /::\~\:\  \
 /:/__/ \:\__\/:/\:\  /\__\/\ \:\ \ \__\/\ \:\ \ \__\/:/\:\ \:\__\
 \:\  \  \/__/\/__\:\/:/  /\:\ \:\ \/__/\:\ \:\ \/__/\/_|::\/:/  /
  \:\  \           \::/  /  \:\ \:\__\   \:\ \:\__\     |:|::/  /
   \:\  \          /:/  /    \:\/:/  /    \:\/:/  /     |:|\/__/
    \:\__\        /:/  /      \::/  /      \::/  /      |:|  |
     \/__/        \/__/        \/__/        \/__/        \|__|
   }

PIECE_HASH = {
  "King" => King,
  "Queen" => Queen,
  "Knight" => Knight,
  "Rook" => Rook,
  "Bishop" => Bishop,
  "Pawn" => Pawn
}

class Game
  def initialize(white, black)
    @player1 = white
    @player2 = black
    @curr_player = @player1
  end

  def play
    @move_outcome = nil
    @start_time = Time.now
    @moves = []

    until @board.checkmate?(:w) || @board.checkmate?(:b)
      system('clear')
      @board.display

      puts @move_outcome unless @move_outcome.nil?
      puts "Check." if @board.in_check?(@curr_playPIECE_HASHer)

      turn

      @curr_player = (@curr_player == @player1 ? @player2 : @player1)
    end

    game_over
  end

  def main_menu
    system('clear')
    puts LOGO
    puts
    puts "Type 'play' to start a standard game of chess."
    puts "Type 'custom' to create a custom board."
    puts "Type 'load' to load saved game."

    entry = gets.chomp.downcase

    if entry == 'play'
      @board = Board.new
    elsif entry == 'custom'
      @board = Board.new(true)
      custom_piece_placement
    elsif entry == 'load'
      load_game
    end

    self.play
  end

  private

  def turn
    begin
      input = @curr_player.get_input

      save_game if input == 's'
      if input == 'q'
        quit_game
        raise ""
      end

      start, target = input.scan(/[a-h]\d/)
      if start.nil? || target.nil?
        raise "Invalid input."
      end

      @move_outcome = make_move(@curr_player.color, parse(start), parse(target))
    rescue RuntimeError => e
      system('clear')
      @board.display
      puts e.message
      retry
    end
    if @board[parse(target)].class == Pawn && @board[parse(target)].can_promote?
      pawn_promote(target)
    end
    @board.moves << [start, target, @curr_player.color]
  end

  def load_game
    puts "Enter filename to load:"
    filename = gets.chomp
    @board = YAML.load_file(filename)
    @curr_player = @board.move_count.even? ? @player1 : @player2
  end

  def save_game
    puts "Enter filename to save game as:"
    filename = gets.chomp
    File.open(filename, 'w') { |file| file.puts @board.to_yaml }
    exit
  end

  def quit_game
    puts "Are you sure you want to quit without saving? (y/n)"
    input = gets.chomp.downcase
    exit if input == 'y'
  end

  def custom_piece_placement
    loop do
      system('clear')
      @board.display

      puts "Enter custom piece to place in this format:"
      puts "color, piece type, position (e.g. 'b queen b3')"
      puts "Start entry with 'd' to remove pieces (e.g. 'd h6')"
      puts "Type 'q' to stop placing pieces."
      begin
        entry = gets.chomp
        break if entry[0] == 'q'
        if entry[0] == 'd'
          pos = parse(entry.split(' ')[1])
          @board[pos] = nil
        else
          piece = parse_piece_string(entry)
          @board[piece.pos] = piece
        end
      rescue
        puts "Invalid format."
        retry
      end
    end
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
      if PIECE_HASH.has_key?(new_class)
        @board.pawn_promote(@board[parse(target)], PIECE_HASH[new_class])
        break
      end
    end
    nil
  end

  def parse_piece_string(input_string)
    color_string, piece_string, pos_string = input_string.split(' ')
    color = color_string.to_sym
    piece_class = PIECE_HASH[piece_string.capitalize]
    pos = parse(pos_string)
    piece_class.new(pos, @board, color)
  end

end

if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new(:w, 'White')
  player2 = HumanPlayer.new(:b, 'Black')
  game = Game.new(player1, player2)
  game.main_menu
end
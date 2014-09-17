#!/usr/bin/env ruby

require_relative 'chess_board'
require_relative 'human_player'

class Game
  def initialize(white, black)
    @board = Board.new
    @player1 = white
    @player2 = black
    @curr_player = @player1
    @piece_hash = { "King" => King, "Queen" => Queen, "Knight" => Knight,
                    "Rook" => Rook, "Bishop" => Bishop, "Pawn" => Pawn}
  end

  def play
    move_outcome = nil
    start_time = Time.now
    start, target = nil, nil
    moves = []
    until @board.checkmate?(:w) || @board.checkmate?(:b)
      system('clear')
      @board.display(moves.last(8))
      begin
        puts move_outcome unless move_outcome.nil?
        puts "Check." if @board.in_check?(@curr_player)
        puts "#{@curr_player.name}'s turn."
        start, target = @curr_player.play_turn
        move_outcome = make_move(@curr_player.color, parse(start), parse(target))
      rescue RuntimeError => e
        puts e.message
        puts "Please select valid move."
        retry
      end
      if @board[parse(target)].class == Pawn && @board[parse(target)].can_promote?
        loop do
          puts "Pawn can be promoted. Input class for new piece."
          new_class = gets.chomp.capitalize
          if @piece_hash.has_key?(new_class)
            @board.pawn_promote(@board[parse(target)], @piece_hash[new_class])
            break
          end
        end
      end
      moves << [start, target, @curr_player.color]
      @curr_player = (@curr_player == @player1 ? @player2 : @player1)
    end

    system('clear')
    @board.display
    winner = @board.checkmate?(:w) ? @player2.name : @player1.name
    puts "CHECKMATE. #{winner} wins."
    puts "Game lasted for #{@board.move_count / 2} turns."
    puts "Game time: #{Time.now - start_time}s"

  end

  private

  def make_move(color, start, target)
    raise "Empty start position" if @board[start].nil?
    raise "Incorrect color piece" if @board[start].color != color
    move_outcome = @board.move(start, target)
  end

  def parse(pos_string)
    letters, numbers = ('a'..'h').to_a, (1..8).to_a.reverse

    [numbers.index(pos_string[1].to_i), letters.index(pos_string[0])]
  end

end

if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new(:w, 'Foo')
  player2 = HumanPlayer.new(:b, 'Bar')
  game = Game.new(player1, player2)
  game.play
end
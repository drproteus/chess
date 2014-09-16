require_relative 'chess_board'
require_relative 'human_player'

class Game
  def initialize(white, black)
    @board = Board.new
    @player1 = white
    @player2 = black
    @move_count = 0
    @curr_player = :w
  end

  def play
    # needs to communicate the correct color to the board
    start_time = Time.now
    until @board.checkmate?(:w) || @board.checkmate?(:b)
      system('clear')
      @board.display
      if @move_count.even?
        begin
          puts "Check." if @board.in_check?(:w)
          puts "Player 1:"
          start, target = @player1.play_turn
          make_move(:w, start, target)
        rescue RuntimeError => e
          puts e.message
          puts "Please select valid move."
          retry
        end
      else
        begin
          puts "Check." if @board.in_check?(:b)
          puts "Player 2:"
          start, target = @player2.play_turn
          make_move(:b, start, target)
        rescue RuntimeError => e
          puts e.message
          puts "Please select valid move."
          retry
        end
      end
      @move_count += 1
    end

    system('clear')
    @board.display
    winner = @board.checkmate?(:w) ? 'Player 2' : 'Player 1'
    puts "CHECKMATE. #{winner} wins."
    puts "Game lasted for #{@move_count / 2} turns."
    puts "Game time: #{Time.now - start_time}s"

  end

  def make_move(color, start, target)
    raise "Empty start position" if @board[start].nil?
    raise "Incorrect color piece" if @board[start].color != color
    @board.move(start, target)
  end

end

if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new
  player2 = HumanPlayer.new
  game = Game.new(player1, player2)
  game.play
end
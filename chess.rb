require_relative 'chess_board'
require_relative 'human_player'

class Game
  def initialize(white, black)
    @board = Board.new
    @player1 = white
    @player2 = black
    @move_count = 0
    @curr_player = @player1
  end

  def play
    # needs to communicate the correct color to the board
    start_time = Time.now
    until @board.checkmate?(:w) || @board.checkmate?(:b)
      system('clear')
      @board.display
      begin
        puts "Check." if @board.in_check?(@curr_player)
          puts "#{@curr_player.name}'s turn."
        start, target = @curr_player.play_turn
        make_move(@curr_player.color, start, target)
      rescue RuntimeError => e
        puts e.message
        puts "Please select valid move."
        retry
      end
      @curr_player = (@curr_player == @player1 ? @player2 : @player1)
      @move_count += 1
    end

    system('clear')
    @board.display
    winner = @board.checkmate?(:w) ? @player2.name : @player1.name
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
  player1 = HumanPlayer.new(:w, 'Foo')
  player2 = HumanPlayer.new(:b, 'Bar')
  game = Game.new(player1, player2)
  game.play
end
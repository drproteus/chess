class HumanPlayer
  attr_reader :color, :name

  def initialize(color, name)
    @color = color
    @name = name
  end

  def play_turn
    print "Input start, target positions: "
    move_string = gets.chomp
    start, target = move_string.scan(/[a-h]\d/)

    [start, target]
  end
end
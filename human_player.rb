class HumanPlayer
  attr_reader :color, :name

  def initialize(color, name)
    @color = color
    @name = name
  end

  def play_turn
    print "Input start, target positions: "
    move_string = gets.chomp
    start, target = move_string.scan(/\D\d/)

    [parse(start), parse(target)]
  end

  def parse(pos_string)
    letters, numbers = ('a'..'h').to_a, (1..8).to_a.reverse

    [numbers.index(pos_string[1].to_i), letters.index(pos_string[0])]
  end
end
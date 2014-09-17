class HumanPlayer
  attr_reader :color, :name

  def initialize(color, name)
    @color = color
    @name = name
  end

  def get_input
    puts "#{@name}'s turn."
    puts
    puts "Enter 's' to save and quit."
    puts "Enter 'q' to quit without saving."
    puts
    print "Input start, target positions: "

    gets.chomp.downcase
  end
end
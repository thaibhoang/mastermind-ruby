class Player
  attr_accessor :current_choice, :color_pool

  def initialize
    @color_pool = %w[red green blue yellow orange grey white black]
    @current_choice = []
    @pool = @color_pool.repeated_permutation(4).to_a
  end

  def random_4
    @current_choice = @color_pool.sample(4)
  end

  def get_four_colors
    @current_choice.clear
    puts 'Type in your choices: (color separated by a space)'
    choice = gets.chomp.split
    p choice
    
    until (choice - (@color_pool)).empty? && choice.size == 4
      puts "Your choice must be a colors in the rule's colors list, type in your choice again: "
      choice = gets.chomp.split
    end
    @current_choice = choice
    puts
  end

  def reduce_pool_size(previous_result, previous_guess)

    new_pool = @pool.select {|guess| (previous_guess & guess).size == previous_result[1] && (previous_guess.zip(guess).count { |elem1, elem2| elem1 == elem2 }) == previous_result[0]}
    number_of_reduced_items = @pool.size - new_pool.size

    return [new_pool, number_of_reduced_items]
  end

  def find_current_best_choice
    
    result = []
    (0..4).each do |a|
      (0..4).each do |b|
        result << [a, b]
      end
    end
    current_best_choice = @pool.reduce([0, []]) do |acumulator, i|   
      min_score = 100000   
      result.each do |subres|
        number_of_reduced_items = reduce_pool_size(subres, i)[1]
        min_score = [min_score, number_of_reduced_items].min
      end
      
      if acumulator[0] <= min_score
        [min_score, i] 
      else
        acumulator      
      end
    end
    @current_choice = current_best_choice[1]
  end

  def smart_computer_choice(previous_result)
    @pool = reduce_pool_size(previous_result, @current_choice)[0]
    find_current_best_choice   
  end

  def starting_smart_computer_guess
    @current_choice = ["red", "red", "green", "green"]
  end

end

class Board
  def initialize
    @board = Array.new(12) { Array.new(4, '*') }
    @guess_result = Array.new(12, '')
    @guess_turn = 0
    @coder = Player.new
    @hacker = Player.new
    @coder_is_computer = true
  end

  def choose_role
    puts 'Do you want to be a coder or a hacker? Coder will make the secret code and hacker will try to find it'
    puts 'Type 1 for coder and 0 for hacker'
    coder_hacker = gets.chomp
    until %w[1 0].include? coder_hacker
      coder_hacker = gets.chomp
      p coder_hacker
      p %w[1 0].include? coder_hacker
    end
    @coder_is_computer = !(coder_hacker == '1')
  end
  
  def check_guess(turn, guess, secret)
    right_position = 0
    right_color = 0
    for i in 0..3
      right_position += 1 if guess[i] == secret[i]
    end
    right_color = (secret & guess).size
    @guess_result[turn] = "  #{right_position} right positions, #{right_color} right colors"
    return [right_position, right_color]
  end

  def receive_guess(guess, secret)
    for i in 0..3
      @board[@guess_turn][i] = guess[i]
    end
    check_guess(@guess_turn, guess, secret)
  end

  def print_board
    puts
    puts "Your color pool: #{@coder.color_pool}"
    puts
    puts "Board:"
    puts
    for i in 0..11
      print '|| -- '
      for j in 0..3
        print "#{@board[i][j]} -- "
      end
      print ' ||'
      puts @guess_result[i]
    end
  end

  def run_game
    choose_role
    print_board
    if @coder_is_computer
      @coder.random_4
      while @coder.current_choice != @hacker.current_choice && @guess_turn < 12
        @hacker.get_four_colors
        receive_guess(@hacker.current_choice, @coder.current_choice)
        print_board
        @guess_turn += 1
      end
      if @coder.current_choice != @hacker.current_choice
        puts 'The secret code is: '
        print @coder.current_choice
        puts
        puts "Computer won. Better luck next time"
      else
        puts 'Congrat you got the secret code!! Hooray!!'
      end

    else
      @coder.get_four_colors
      @hacker.starting_smart_computer_guess
      result = receive_guess(@hacker.current_choice, @coder.current_choice)
      print_board
      @guess_turn += 1
      while @coder.current_choice != @hacker.current_choice && @guess_turn < 12
        sleep(1)
        p result
        @hacker.smart_computer_choice(result)
        result = receive_guess(@hacker.current_choice, @coder.current_choice)
        print_board
        @guess_turn += 1
      end
      if @coder.current_choice == @hacker.current_choice
        puts 'The computer found out your code!! Might try to update the code next time'
      else
        puts "Computer failed to find your code. You won!! Hooray!!"
      end
    end
  end
end

board = Board.new
board.run_game



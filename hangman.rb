# frozen_string_literal: true

require 'yaml'
require './save_load'

# class for one instance of the hangman game
class Hangman
  attr_reader :good_words, :code_word, :display, :win, :bad_guesses

  def create_new_game
    @code_word = pick_random_word
    @display = []
    @used_letters = []
    @bad_guesses = 0
    @win = false
  end

  def create_words
    possible_words = []
    lines = File.readlines('all_words.txt')
    lines.each do |word|
      word = word.chomp
      possible_words.append(word) if word.length <=12 && word.length >=5
    end
    possible_words
  end

  def pick_random_word
    possible_words = create_words
    index = rand(0..possible_words.length)
    possible_words[index]
  end

  def one_round
    ask_for_input
    unless (@input == 'save')
      check_guess(@input)
      puts show_array(@display)
      puts "Used letters: #{show_array(@used_letters)} \n"
      puts "Missed tries: #{@bad_guesses}; misses remaining: #{5-@bad_guesses}\n\n"
      check_win
    end
  end

  def create_display
    @code_word.length.times do
      @display.append('_')
    end
    @display
  end

  def ask_for_input
    puts 'Please enter your guess or type save to save your game'
    @input = gets.chomp.downcase
    if @input.match?(/^\p{L}$/) && !@used_letters.include?(@input)
      @used_letters.append(@input)
    elsif @input == 'save'
      save_game
      puts 'You saved the game!'
    else
      puts 'That is not a valid input'
      ask_for_input
    end
  end

  def check_guess(input)
    if @code_word.include?(input)
      @code_word.split('').each_with_index do |char, index|
        @display[index] = char if char == input
      end
      puts 'That was a good guess!'
    else
      puts "That wasn't a great guess :( \n\n"
      @bad_guesses += 1
    end
  end

  def show_array(array)
    temp = ''
    array.each do |char|
      temp += "#{char} "
    end
    temp
  end

  def check_win
    if !@display.include?("_")
      @win = true
      puts 'Congratulations, you guessed the word!'
    end
  end

  def play_game
    puts 'Do you want to play a new game or load an old one?'
    puts 'Type NEW if you want to play a new game'
    puts 'Type LOAD if you want to load a saved file'
    choice = gets.chomp.downcase
    if choice == 'new'
      new_game
    elsif choice == 'load'
      loaded_game
    else
      puts 'thats not a valid choice, please pick again'
    end
  end

  def load_save
    file = YAML.safe_load(File.read('save.yaml'))
    @code_word = file['code_word']
    @display = file['display']
    @used_letters = file['used_letters']
    @bad_guesses = file['bad_guesses']
    @win = file['win']
  end

  def save_game()
    File.open('save.yaml','w') {|f| f.write to_yaml}
  end

  def to_yaml
    YAML.dump(
      'code_word' => @code_word,
      'display' => @display,
      'used_letters' => @used_letters,
      'bad_guesses' => @bad_guesses,
      'win' => @win )
  end

  def new_game
    create_new_game
    create_display
    puts show_array(@display)
    while @bad_guesses <= 4 && !@win
      one_round
    end
    puts "I'm sorry but you lost" unless @win
    puts "The word we were looking for was #{@code_word}\n\n" unless @win
  end

  def loaded_game
    load_save
    puts show_array(@display)
    puts "Used letters: #{show_array(@used_letters)} \n"
    puts "Missed tries: #{@bad_guesses}; misses remaining: #{5-@bad_guesses}\n\n"
    while @bad_guesses <= 4 && !@win
      one_round
    end
    puts "I'm sorry but you lost" unless @win
    puts "The word we were looking for was #{@code_word}\n\n"
  end
end

game = Hangman.new
game.play_game

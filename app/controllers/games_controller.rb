class GamesController < ApplicationController
  def new
    @letters = generate_letters
  end

  def score
    @word = params[:word].upcase
    @letters = params[:letters].split(' ')
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @time_taken = @end_time - @start_time

    @result = check_word(@word, @letters)
    @score = calculate_score(@word, @time_taken, @result[:valid])

    session[:total_score] ||= 0
    session[:total_score] += @score
    @total_score = session[:total_score]
  end

  private

  def generate_letters
    vowels = %w[A E I O U]
    consonants = %w[B C D F G H J K L M N P Q R S T V W X Y Z]

    letters = []

    4.times { letters << vowels.sample }
    6.times { letters << consonants.sample }

    letters.shuffle
  end

  def check_word(word, letters)
    word_letters = word.chars
    available_letters = letters.dup

    can_be_formed = word_letters.all? do |letter|
      if available_letters.include?(letter)
        available_letters.delete_at(available_letters.index(letter))
        true
      else
        false
      end
    end

    return { valid: false, message: "The word cannot be formed with the given letters." } unless can_be_formed

    english_word = check_english_word(word)

    if english_word
      { valid: true, message: "
      Well done! Valid word" }
    else
      { valid: false, message: "it's not a valid English word." }
    end
  end

  def check_english_word(word)
    begin
      url = "https://dictionary.lewagon.com/#{word}"
      response = URI.open(url).read
      data = JSON.parse(response)
      data['found']
    rescue
      false
    end
  end

  def calculate_score(word, time_taken, is_valid)
    return 0 unless is_valid

    base_score = word.length
    time_bonus = [0, (60 - time_taken)].max / 10.0
    (base_score + time_bonus).round(2)
  end
end

require './lib/roman_converter'
class FileProcessor

  def initialize(file_path)
    @questions = []
    @token_to_roman_map = {}
    @token_to_integer_map = {}
    @missing_value_lines = []
    @element_values = {}
    @file = File.new(file_path, 'r')
    @roman_converter = RomanConverter.new
  end

  def process
    while(line = @file.gets)
      process_line(line)
    end
  end

  def output
    reply = []
    @questions.each do |quest|
      down_quest = quest.downcase
      reply << value_of_roman(quest) if down_quest.start_with?('how much')
      reply << value_of_element(quest) if down_quest.start_with?('how many')
    end
    puts reply.join("\n")
  end

  def token_to_integer
    @token_to_roman_map.each do |key, value|
      @token_to_integer_map[key] = @roman_converter.roman_to_number(value)
    end
    find_missing_values
  end

  private
  def process_line(line)
    line = line.strip.gsub(/\s+/, ' ')
    words = line.split(' ')
    @questions << line if line.end_with?('?')
    @token_to_roman_map[words.first.to_sym] = words.last if words.count == 3 && words[1].downcase == 'is'
    @missing_value_lines << line if line.downcase.end_with?('credits')
  end

  def find_missing_values
    @missing_value_lines.each do |line|
      process_missing_line(line)
    end
  end

  def process_missing_line(line)
    words = line.split(' ')
    credit = 0
    element = nil
    element_values = nil
    split_index = 0
    words.each_with_index do  |word, index|
      if word.downcase.eql?('credits')
        credit = words[index-1].to_i
      end
      if word.downcase.eql?('is')
        split_index = index-1
        element = words[index-1]
      end
      element_values = words[0..split_index]
    end

    roman_number = ''
    element_values.each do |element_value|
      roman_number += @token_to_roman_map[element_value.to_sym] if @token_to_roman_map[element_value.to_sym]
    end
    element_value_in_number = @roman_converter.roman_to_number(roman_number)
    @element_values[element.to_sym] = (credit/element_value_in_number).to_f
  end



  def value_of_roman(quest)
    if input_valid?(quest)
      quest_tokens = quest.split(' ')
      valid_tokens = get_valid_tokens(quest_tokens)
      token_to_roman = valid_tokens.map do |tok|
        @token_to_roman_map[tok.to_sym] if @token_to_roman_map[tok.to_sym]
      end
      value = @roman_converter.roman_to_number(token_to_roman.join)
      valid_tokens << 'is'
      valid_tokens << value.to_s

      valid_tokens.join(' ')
    else
      'I have no idea what you are talking about'
    end
  end

  def value_of_element(quest)
    error  = 'I have no idea what you are talking about'
    if input_valid?(quest)
      quest_tokens = quest.split(' ')
      valid_tokens = get_valid_tokens(quest_tokens)
      element = nil

      token_to_roman = valid_tokens.map do |tok|
        tok_to_rom = nil
        tok_to_rom = @token_to_roman_map[tok.to_sym] if @token_to_roman_map[tok.to_sym]
        element = tok.to_sym if @element_values[tok.to_sym]
        tok_to_rom
      end.compact

      return error unless element && token_to_roman.any?

      element_value = (@roman_converter.roman_to_number(token_to_roman.join) * @element_values[element]).to_i
      valid_tokens << 'is'
      valid_tokens << element_value.to_s
      valid_tokens << 'Credits'

      valid_tokens.join(' ')
    else
      error
    end
  end

  def get_valid_tokens(tokens)
    start_index = tokens.index('is') + 1
    end_index = tokens.index('?') -1
    tokens[start_index..end_index]
  end

  def input_valid?(quest)
    (/^how(.*(\bis\b).*[\s][*?])$/i === quest)
  end

end

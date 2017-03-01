
class RomanConverter
  ROMAN_SYMBOLS_NUMERIC_MAPPING = {I: 1, V: 5, X: 10, L: 50, C: 100, D: 500, M: 1000}.freeze
  ROMAN_SUBTRACTABLE = {1 => [5, 10], 5 => [], 10=>[50,100], 50 => [], 100 => [500, 1000]}.freeze
  ROMAN_SYMBOLS = ROMAN_SYMBOLS_NUMERIC_MAPPING.keys.map(&:to_s).freeze
  NON_REP_ROMAN_SYMBOLS = %w(D L V).freeze
  REP_ROMAN_SYMBOLS = %w(I V X M).freeze

  ROMAN_SYMBOLS_COUNTS =
    ROMAN_SYMBOLS_NUMERIC_MAPPING.inject({}) do |hash, (key, _value)|
      hash.merge key => 0
    end.freeze

  NON_REP_ROMAN_SYMBOLS_COUNTS =
    ROMAN_SYMBOLS_COUNTS.select do |key, _value|
      NON_REP_ROMAN_SYMBOLS.include?(key.to_s)
    end.freeze

  REP_ROMAN_SYMBOLS_COUNTS =
    ROMAN_SYMBOLS_COUNTS.select do |key, _value|
      REP_ROMAN_SYMBOLS.include?(key.to_s)
    end.freeze

  def initialize
    reset_symbol_count
  end

  def roman_to_number(roman_number)
    number = 0
    last_number = 0
    roman_symbols = roman_number.split('')
    roman_symbols.each do |roman_symbol|
      if symbol_count_valid?(roman_symbol.to_sym)
        roman_symbol_value = ROMAN_SYMBOLS_NUMERIC_MAPPING[roman_symbol.to_sym]
        number = find_roman_number_value(roman_symbol_value, last_number, number)
        last_number = roman_symbol_value
      end
    end
    reset_symbol_count
    number
  end

  private
  def reset_symbol_count
    @non_rep_symbol_counts = NON_REP_ROMAN_SYMBOLS_COUNTS.dup
    @rep_symbol_counts = REP_ROMAN_SYMBOLS_COUNTS.dup
  end

  def symbol_count_valid?(roman_symbol)
    return false unless ROMAN_SYMBOLS.include?(roman_symbol.to_s)
    if NON_REP_ROMAN_SYMBOLS.include?(roman_symbol.to_s)
      @non_rep_symbol_counts[roman_symbol] = @non_rep_symbol_counts[roman_symbol] + 1
      if @non_rep_symbol_counts.has_value?(3)
        puts "Roman symbol #{NON_REP_ROMAN_SYMBOLS.join(',')} cannot be repeated."
        return false
      end
      true
    elsif REP_ROMAN_SYMBOLS.include?(roman_symbol.to_s)
      key_with_value_three  = @rep_symbol_counts.key(3)
      if key_with_value_three
        if roman_symbol == key_with_value_three
          puts "Roman symbol #{roman_symbol} cannot be repeate more than 3 times continuously"
          return false
        else
          if ROMAN_SYMBOLS_NUMERIC_MAPPING[roman_symbol] < ROMAN_SYMBOLS_NUMERIC_MAPPING[key_with_value_three]
            @rep_symbol_counts[roman_symbol] = @rep_symbol_counts[roman_symbol] + 1
            @rep_symbol_counts[key_with_value_three] = 0
            return true
          else
            puts "Symbol should not be grater than #{roman_symbol}"
            return false
          end
        end
      else
        @rep_symbol_counts[roman_symbol] = @rep_symbol_counts[roman_symbol] + 1
        return true
      end
    end
  end


  def find_roman_number_value(roman_symbol_value, last_number, number)
    if last_number < roman_symbol_value && ROMAN_SUBTRACTABLE[last_number] && ROMAN_SUBTRACTABLE[last_number].include?(roman_symbol_value)
      roman_symbol_value - number
    else
      number + roman_symbol_value
    end
  end

end

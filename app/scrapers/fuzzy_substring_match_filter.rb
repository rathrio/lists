# Forward only results that exhibit a substring match with
# the used query word.
class FuzzySubstringMatchFilter

  attr_reader :matches

  TOLERATED_ERRORS = 0
  DELIMITERS = [
    '-',
    '/',
    ' '
  ]

  # @param result [Array<Hash> #name] retrieved results
  # @param query [String] user search word
  def initialize(results, query)
    @matches = results.select do |result|
      result_name = normalized_word(result[:name])
      query_name = normalized_word(query)
      distance_between_close_enough?(result_name, query_name)
    end
  end

  def distance_between_close_enough?(word, substring)
    n = substring.length 
    splits = (split_word word).select { |word| word.length == n }
    splits.any? do |s|
      n - overlapping_chararcters(s, substring) == TOLERATED_ERRORS
    end
  end

  def overlapping_chararcters(s, substring)
    sum = 0
    n = s.length
    n.times do |idx|
      sum += 1 if (s[idx].eql? substring[idx])
    end
    sum
  end

  # Down-cases and removes all delimiter tokens from a given word.
  # 
  # @example
  #   normalized_word("FooBar-Pew)
  #   #=> "foobarpew"
  #   
  # @param word [String] unnormalized word
  # @return [String] downcased, delimiter-less word.
  def normalized_word(word)
    tmp = word.downcase
    DELIMITERS.each do |delimiter|
      tmp = tmp.gsub(delimiter, '')
    end
    tmp
  end

  # Obtain all substring of a given word.
  # 
  # @example
  #   split_word("abc")
  #   #=> ["a", "ab", "abc", "b", "bc", "c"]
  # 
  # @param s [String] word to split
  # @return [Array<String>] collection of substrings of a given word.
  def split_word(s)
    indices = (0...s.length).to_a
    indices.product(indices).reject{|i,j| i > j}.map{|i,j| s[i..j]}.uniq
  end

end

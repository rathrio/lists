# Forward only results that exhibit a substring match with
# a given query word.
#
# This filter is used to reduce the number of false positive results provided
# by our scappers and is used within the ScraperResultsController class.
class FuzzySubstringMatchFilter

  attr_reader :matches

  # Defines how many errors are tolerated to accept a string comparison
  # as a good match.
  TOLERATED_ERRORS = 0

  # Delimiters are ignored for determining the matching quality
  DELIMITERS = [
    '-',
    '/',
    ' '
  ].freeze

  # @param result [Array<Hash> #name] retrieved results
  # @param query [String] user search word
  def initialize(results, query)
    @matches = results.select do |result|
      result_name = normalized_word(result[:name])
      query_name = normalized_word(query)
      words_are_similar_enough?(result_name, query_name)
    end
  end

  # Tests whether there is a substring of a given result,
  # which has sufficient many overlapping characters.
  #
  # @example
  #   words_are_similar_enough?("foobarbaz", "bar")
  #   #=> true
  #   words_are_similar_enough?("hanspeter", "nils")
  #   #=> false
  #
  # @param result [String] a normalized result fetched by a scapper.
  # @param query [String] a normalized query word provided by the user.
  # @return [Boolean] true if there is a substring in the result, that has
  #   sufficient many matches with the given query word, otherwise false.
  def words_are_similar_enough?(result, query)
    n = query.length
    substrings_of_length_n = (substrings_for result).select { |substring| substring.length == n }
    substrings_of_length_n.any? do |substring|
      number_of_missmatches = n - overlapping_character_count(substring, query)
      number_of_missmatches <= TOLERATED_ERRORS
    end
  end

  # Count the number of overlapping characters for
  # two given equally sized words.
  #
  # @example
  #   overlapping_character_count("foobaz", "foobar")
  #   #=> 5
  #
  # @param word_a [String] some word
  # @param word_b [String] some word
  # @return [Integer] number of overlapping characters between
  #   the two given words.
  def overlapping_character_count(word_a, word_b)
    overlap_count = 0
    word_length = word_a.length
    word_length.times do |idx|
      overlap_count += 1 if word_a[idx].eql?(word_b[idx])
    end
    overlap_count
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

  # Obtain all substring combinations of a given word.
  #
  # @example
  #   substrings_for("abc")
  #   #=> ["a", "ab", "abc", "b", "bc", "c"]
  #
  # @param s [String] word to split
  # @return [Array<String>] collection of substrings of a given word.
  def substrings_for(word)
    indices = (0...word.length).to_a
    upper_triangle = indices.product(indices).reject { |i, j| i > j }
    upper_triangle.map { |i, j| word[i..j] }.uniq
  end

end

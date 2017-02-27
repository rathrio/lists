require 'test_helper'

class FuzzySubstringMatchFilterTest < ActiveSupport::TestCase

  test 'Only matches partial substrings' do
    results = [
      { name: "He Man: Vol 1" },
      { name: "The He Man: Vol 1" },
      { name: "Her Men: Vol 1" },
      { name: "Simpons - He is the real man" }
    ]

    gt = [
      "He Man: Vol 1",
      "The He Man: Vol 1"
    ]

    matches = FuzzySubstringMatchFilter.new(results, "He-Man").matches
    matches.each do |match|
      assert gt.include?(match[:name])
    end
  end

  test 'Filter is case insensitive' do
    fm = FuzzySubstringMatchFilter
    gt = "He Man: Vol 1"
    results = [
      { name: gt },
      { name: "Simpons - He is the real man" }
    ]

    assert_equal(gt, fm.new(results, "He-Man").matches[0][:name])
    assert_equal(gt, fm.new(results, "he-man").matches[0][:name])
    assert_equal(gt, fm.new(results, "He-man").matches[0][:name])
    assert_equal(gt, fm.new(results, "he-Man").matches[0][:name])
    assert_equal(gt, fm.new(results, "hE-MaN").matches[0][:name])
    assert_equal(gt, fm.new(results, "He-mAn").matches[0][:name])
  end

  test '#word_are_similar_enough?' do
    fm = FuzzySubstringMatchFilter.new([], '')
    assert fm.words_are_similar_enough?("foo", "foo")
    assert fm.words_are_similar_enough?("foobar", "foo")
    assert fm.words_are_similar_enough?("pewfoobar", "foo")
    refute fm.words_are_similar_enough?("pewfoobar", "pow")
    refute fm.words_are_similar_enough?("", "pow")
    refute fm.words_are_similar_enough?("Pow", "pow")
    refute fm.words_are_similar_enough?("hanspeter", "nils")
    assert fm.words_are_similar_enough?("hanspeter", "hans")
    assert fm.words_are_similar_enough?("hanspeter", "peter")
  end

  test '#overlapping_chararcters' do
    fm = FuzzySubstringMatchFilter.new([], '')
    assert_equal(0, fm.overlapping_character_count("", ""))
    assert_equal(3, fm.overlapping_character_count("foo", "foo"))
    assert_equal(0, fm.overlapping_character_count("Otto", "Nils"))
    assert_equal(5, fm.overlapping_character_count("foobar", "foobaz"))
    assert_equal(5, fm.overlapping_character_count("foobaz", "foobar"))
  end

  test 'Filter does not consider DELIMITERS' do
    fm = FuzzySubstringMatchFilter
    gt = "He Man: Vol 1"
    results = [
      { name: gt },
      { name: "Simpons - He is the real man" }
    ]

    fm::DELIMITERS.each do |delimiter|
      query = "He#{delimiter}Man"
      assert_equal(gt, fm.new(results, query).matches[0][:name])
    end
  end

  test '#normalized_word' do
    fm = FuzzySubstringMatchFilter.new([], '')
    assert_equal("foobar", fm.normalized_word("FOOBAR"))
    assert_equal("foobar", fm.normalized_word("FOO-BAR"))
    assert_equal("foobar", fm.normalized_word("FOO BAR"))
    assert_equal("foobar", fm.normalized_word("FOO/BAR"))
  end

  test "#substrings_for" do
    fm = FuzzySubstringMatchFilter.new([], '')
    gt_splits = %w(a ab abc b bc c)

    substrings = fm.substrings_for("abc")
    substrings.each do |split|
      assert gt_splits.include?(split)
    end

    gt_splits.each do |split|
      assert substrings.include?(split)
    end
  end

end

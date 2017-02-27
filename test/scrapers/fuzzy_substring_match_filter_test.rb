require 'test_helper'

class FuzzySubstringMatchFilterTest < ActiveSupport::TestCase

  test 'Only matches partial substrings' do
    results = [
      {name: "He Man: Vol 1"},
      {name: "The He Man: Vol 1"},
      {name: "Her Men: Vol 1"},
      {name: "Simpons - He is the real man"}
    ]

    gt = [
      "He Man: Vol 1",
      "The He Man: Vol 1"
    ]

    matches = FuzzySubstringMatchFilter.new(results, "He-Man").matches
    matches.each do |match|
      assert(gt.include? match[:name])
    end
  end

  test 'Filter is case insensitive' do
    fm = FuzzySubstringMatchFilter
    gt = "He Man: Vol 1"
    results = [
      {name: gt},
      {name: "Simpons - He is the real man"}
    ]

    assert_equal(gt, fm.new(results, "He-Man").matches[0][:name])
    assert_equal(gt, fm.new(results, "he-man").matches[0][:name])
    assert_equal(gt, fm.new(results, "He-man").matches[0][:name])
    assert_equal(gt, fm.new(results, "he-Man").matches[0][:name])
    assert_equal(gt, fm.new(results, "hE-MaN").matches[0][:name])
    assert_equal(gt, fm.new(results, "He-mAn").matches[0][:name])
  end

  test 'Filter does not consider DELIMITERS' do
    fm = FuzzySubstringMatchFilter
    gt = "He Man: Vol 1"
    results = [
      {name: gt},
      {name: "Simpons - He is the real man"}
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

  test "#split_word" do
    fm = FuzzySubstringMatchFilter.new([], '')
    gt_splits = [
      "a", "ab", "abc", "b", "bc", "c"
    ]

    splits = fm.split_word("abc")
    splits.each do |split|
      assert(gt_splits.include? split)
    end

    gt_splits.each do |split|
      assert(splits.include? split)
    end
  end

end

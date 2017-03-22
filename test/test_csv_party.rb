require "minitest/autorun"
Dir[File.dirname(__FILE__) + '/importers/*.rb'].each {|file| require file }

class CSVPartTest < Minitest::Test
  def test_happy_path
    importer = HappyPathImporter.new("test/csv/happy_path.csv").import!
    assert_equal "Widget", $result[:product]
    assert_equal 9.99,     $result[:price]
  end

  def test_raw_parser
    importer = RawParserImporter.new("test/csv/raw_parser.csv").import!
    assert_equal " has whitespace ", $result[:raw]
  end

  def test_string_parser
    importer = StringParserImporter.new("test/csv/string_parser.csv").import!
    assert_equal "has whitespace", $result[:string]
  end

  def test_boolean_parser
    importer = BooleanParserImporter.new("test/csv/boolean_parser.csv").import!
    assert $result[:t]
    assert $result[:T]
    assert $result[:true]
    assert $result[:TRUE]
    assert $result[:one]
    assert $result[:true_whitespace]
    refute $result[:f]
    refute $result[:F]
    refute $result[:false]
    refute $result[:FALSE]
    refute $result[:zero]
    refute $result[:two]
    refute $result[:random]
  end

  def test_integer_parser
    IntegerParserImporter.new("test/csv/integer_parser.csv").import!
    assert_equal 42,    $result[:integer]
    assert_equal 42.00, $result[:decimal_as_integer]
  end

  def test_decimal_parser
    flunk
  end

  def test_custom_parser
    flunk
  end

  def test_named_custom_parser
    flunk
  end

  # def test_requires_valid_built_in_parser
  #   flunk
  # end

  # def test_requires_either_built_in_parser_or_block
  #   flunk
  # end

  # def test_requires_a_column_header
  #   flunk
  # end

  # def test_does_not_allow_a_column_to_be_defined_twice
  #   flunk
  # end

  # def test_strips_whitespace_from_a_column_by_default
  #   flunk
  # end
end

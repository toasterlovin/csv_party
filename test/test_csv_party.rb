require "minitest/autorun"
Dir[File.dirname(__FILE__) + '/importers/*.rb'].each {|file| require file }

class CSVPartTest < Minitest::Test
  def test_happy_path
    importer = HappyPathImporter.new("test/csv/happy_path.csv").import!
    assert_equal "Widget", $result[:product]
    assert_equal 9.99,     $result[:price]
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

  # def test_casts_column_to_the_raw_value
  #   flunk
  # end

  # def test_casts_column_to_boolean
  #   flunk
  # end

  # def test_casts_column_to_integer
  #   flunk
  # end

  # def test_casts_column_to_decimal
  #   flunk
  # end

  # def test_casts_column_with_passed_block
  #   flunk
  # end

  # def test_allows_definition_of_named_parsers
  #   flunk
  # end
end

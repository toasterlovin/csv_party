require "minitest/autorun"
require "./test_importer"

class BetterCsvTest < Minitest::Test
  def setup
    @importer = TestImporter.new("test.csv")
  end

  def test_importing
    @importer.import!
  end

  def test_requires_valid_built_in_parser
    flunk
  end

  def test_requires_either_built_in_parser_or_block
    flunk
  end

  def test_requires_a_column_header
    flunk
  end

  def test_does_not_allow_a_column_to_be_defined_twice
    flunk
  end

  def test_strips_whitespace_from_a_column_by_default
    flunk
  end

  def test_casts_column_to_the_raw_value
    flunk
  end

  def test_casts_column_to_boolean
    flunk
  end

  def test_casts_column_to_integer
    flunk
  end

  def test_casts_column_to_decimal
    flunk
  end

  def test_casts_column_with_passed_block
    flunk
  end

  def test_allows_definition_of_named_parsers
    flunk
  end
end

require 'test_helper'

class ParserTest < Minitest::Test
  def test_raw_parser
    importer = RawParserImporter.new('test/csv/raw_parser.csv')
    importer.import!

    assert_equal ' has whitespace ', importer.result.raw
  end

  def test_string_parser
    importer = StringParserImporter.new('test/csv/string_parser.csv')
    importer.import!

    assert_equal 'has whitespace', importer.result.string
  end

  def test_boolean_parser
    importer = BooleanParserImporter.new('test/csv/boolean_parser.csv')
    importer.import!

    assert importer.result.t
    assert importer.result.T
    assert importer.result.true
    assert importer.result.TRUE
    assert importer.result.one
    assert importer.result.true_whitespace
    refute importer.result.f
    refute importer.result.F
    refute importer.result.false
    refute importer.result.FALSE
    refute importer.result.zero
    refute importer.result.two
    refute importer.result.random
  end

  def test_integer_parser
    importer = IntegerParserImporter.new('test/csv/integer_parser.csv')
    importer.import!

    assert_equal(42, importer.result.integer)
    assert_equal(-42, importer.result.negative_integer)
    assert_equal(-42, importer.result.negative_accounting_integer)
    assert_equal(42, importer.result.whitespace)
    assert_equal(42, importer.result.decimal)
    assert_equal(-42, importer.result.negative_decimal)
    assert_equal(-42, importer.result.negative_accounting_decimal)
    assert_nil importer.result.whitespace_only
    assert_nil importer.result.blank
  end

  def test_decimal_parser
    importer = DecimalParserImporter.new('test/csv/decimal_parser.csv')
    importer.import!

    assert_equal(42.42, importer.result.decimal)
    assert_equal(-42.42, importer.result.negative_decimal)
    assert_equal(42.42, importer.result.whitespace)
    assert_equal(42.42, importer.result.dollars)
    assert_equal(-42.42, importer.result.negative_dollars)
  end

  def test_custom_parser
    importer = CustomParserImporter.new('test/csv/custom_parser.csv')
    importer.import!

    assert_equal 'value plus added text', importer.result.custom
  end

  def test_named_custom_parser
    importer = NamedCustomParserImporter.new('test/csv/named_custom_parser.csv')
    importer.import!

    assert_equal 'value 1 plus added text', importer.result.custom_1
    assert_equal 'value 2 plus added text', importer.result.custom_2
  end

  def test_parses_as_string_by_default
    csv_path = 'test/csv/parses_as_string_by_default.csv'
    importer = ParsesAsStringByDefaultImporter.new(csv_path)
    importer.import!

    assert_equal 'removed whitespace', importer.result.whitespace
  end

  def test_parses_blanks_as_nil
    importer = BlanksAsNilImporter.new('test/csv/blanks_as_nil.csv')
    importer.import!

    assert_nil importer.result.empty
    assert_nil importer.result.blank
    assert_nil importer.result.integer
    assert_nil importer.result.decimal
    assert_nil importer.result.boolean
    assert_equal ' ', importer.result.raw_blank
    assert_nil importer.result.custom
    assert_equal 'Not nil', importer.result.opt_out
  end

  def test_unknown_named_parser
    assert_raises CSVParty::UnknownParserError do
      UnknownNamedParserImporter.new('test/csv/unknown_named_parser.csv')
    end
  end
end

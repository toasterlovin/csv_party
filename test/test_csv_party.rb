require 'minitest/autorun'
Dir[File.dirname(__FILE__) + '/importers/*.rb'].each {|file| require file }

class CSVPartyTest < Minitest::Test
  def test_happy_path
    $result = []
    HappyPathImporter.new('test/csv/happy_path.csv').import!

    row_one = $result[0]
    assert_equal 'Widget', row_one.product
    assert_equal 9.99,     row_one.price

    row_two = $result[1]
    assert_equal 'Gadget', row_two.product
    assert_equal 12.99,    row_two.price
  end

  def test_raw_parser
    RawParserImporter.new('test/csv/raw_parser.csv').import!
    assert_equal ' has whitespace ', $result.raw
  end

  def test_string_parser
    StringParserImporter.new('test/csv/string_parser.csv').import!
    assert_equal 'has whitespace', $result.string
  end

  def test_boolean_parser
    BooleanParserImporter.new('test/csv/boolean_parser.csv').import!
    assert $result.t
    assert $result.T
    assert $result.true
    assert $result.TRUE
    assert $result.one
    assert $result.true_whitespace
    refute $result.f
    refute $result.F
    refute $result.false
    refute $result.FALSE
    refute $result.zero
    refute $result.two
    refute $result.random
  end

  def test_integer_parser
    IntegerParserImporter.new('test/csv/integer_parser.csv').import!
    assert_equal 42,    $result.integer
    assert_equal 42,    $result.whitespace
    assert_equal 42.00, $result.decimal_as_integer
    assert_nil $result.whitespace_only
    assert_nil $result.blank
  end

  def test_decimal_parser
    DecimalParserImporter.new('test/csv/decimal_parser.csv').import!
    assert_equal 42.42, $result.decimal
    assert_equal 42.42, $result.whitespace
    assert_equal 42.42, $result.dollars
  end

  def test_custom_parser
    CustomParserImporter.new('test/csv/custom_parser.csv').import!
    assert_equal 'value plus added text', $result.custom
  end

  def test_named_custom_parser
    NamedCustomParserImporter.new('test/csv/named_custom_parser.csv').import!
    assert_equal 'value 1 plus added text', $result.custom_1
    assert_equal 'value 2 plus added text', $result.custom_2
  end

  def test_parses_as_string_by_default
    ParsesAsStringByDefaultImporter.new('test/csv/parses_as_string_by_default.csv').import!
    assert_equal 'removed whitespace', $result.whitespace
  end

  def test_unknown_named_parser
    assert_raises UnknownParserError do
      UnknownNamedParserImporter.new('test/csv/unknown_named_parser.csv')
    end
  end

  def test_requires_column_header
    assert_raises MissingHeaderError do
      require 'importers/invalid/requires_column_header_importer'
    end
  end

  def test_duplicate_columns
    assert_raises DuplicateColumnError do
      require 'importers/invalid/duplicate_columns_importer'
    end
  end

  def test_missing_column_in_csv
    assert_raises MissingColumnError do
      MissingColumnImporter.new('test/csv/missing_column.csv')
    end
  end

  def test_provides_access_to_raw_row_values_in_import_block
    UnparsedRowValuesImporter.new('test/csv/unparsed_row_values.csv').import!
    assert_equal "Has whitespace", $result.whitespace
    assert_equal " Has whitespace ", $result.unparsed.whitespace
  end

  def test_provides_access_to_csv_row_as_string
    csv_file_path = 'test/csv/csv_row_as_string.csv'
    CsvRowAsStringImporter.new(csv_file_path).import!
    puts $result
    assert_equal "Some text", $result.column_1
    assert_equal IO.readlines(csv_file_path)[1], $result.csv_string
  end
end

require 'minitest/autorun'
require 'securerandom'
Dir[File.dirname(__FILE__) + '/importers/*.rb'].each { |file| require file }

class CSVParty
  # Add an instance level attribute for passing results back to tests
  attr_accessor :result
end

class CSVPartyTest < Minitest::Test
  def test_happy_path
    importer = HappyPathImporter.new('test/csv/happy_path.csv')
    importer.result = []
    importer.import!

    row_one = importer.result[0]
    assert_equal 'Widget', row_one.product
    assert_equal 9.99,     row_one.price

    row_two = importer.result[1]
    assert_equal 'Gadget', row_two.product
    assert_equal 12.99,    row_two.price
  end

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

    assert_equal 42,    importer.result.integer
    assert_equal 42,    importer.result.whitespace
    assert_equal 42.00, importer.result.decimal_as_integer
    assert_nil importer.result.whitespace_only
    assert_nil importer.result.blank
  end

  def test_decimal_parser
    importer = DecimalParserImporter.new('test/csv/decimal_parser.csv')
    importer.import!

    assert_equal 42.42, importer.result.decimal
    assert_equal 42.42, importer.result.whitespace
    assert_equal 42.42, importer.result.dollars
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
    importer = UnparsedRowValuesImporter.new('test/csv/unparsed_row_values.csv')
    importer.import!

    assert_equal 'Has whitespace', importer.result.whitespace
    assert_equal ' Has whitespace ', importer.result.unparsed.whitespace
  end

  def test_provides_access_to_csv_row_as_string
    csv_file_path = 'test/csv/csv_row_as_string.csv'
    importer = CsvRowAsStringImporter.new(csv_file_path)
    importer.import!

    assert_equal 'Some text', importer.result.column_1
    assert_equal IO.readlines(csv_file_path)[1], importer.result.csv_string
  end

  def test_captures_malformed_csv_errors
    importer = MalformedCSVErrorImporter.new('test/csv/malformed_csv_error.csv')
    importer.import!

    assert importer.result.first.is_a? CSV::MalformedCSVError
    assert_equal 2, importer.result.last
  end

  def test_provides_access_to_external_dependencies
    column = SecureRandom.random_number
    rows = SecureRandom.random_number
    errors = SecureRandom.random_number
    importer = ExternalDependencyImporter.new(
      'test/csv/external_dependency.csv',
      dependencies: {
        column: column,
        rows: rows,
        errors: errors
      }
    )
    importer.result = {}
    importer.import!

    assert_equal column, importer.result[:column]
    assert_equal rows, importer.result[:rows]
    assert_equal errors,  importer.result[:errors]
  end
end

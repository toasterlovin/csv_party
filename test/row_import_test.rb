require 'test_helper'

class RowImportTest < Minitest::Test
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

  def test_provides_access_to_csv_row_number
    importer = RowNumberImporter.new('test/csv/row_number.csv')
    importer.import!

    assert_equal 3, importer.result.row_number
  end

  def test_raises_error_if_row_processor_is_undefined
    importer = UndefinedRowProcessorImporter
               .new('test/csv/undefined_row_processor.csv')

    assert_raises CSVParty::UndefinedRowProcessorError do
      importer.import!
    end
  end

  def test_raises_error_when_accessing_undefined_column
    importer = UndefinedColumnImporter.new('test/csv/undefined_column.csv')

    assert_raises NoMethodError do
      importer.import!
    end
  end
end

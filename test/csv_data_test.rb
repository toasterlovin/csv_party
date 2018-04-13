require 'test_helper'

class CsvDataTest < Minitest::Test
  class CsvImporter < CSVParty::Importer
    column :column_1
    column :column_2

    rows do |row|
      self.result = row
    end
  end

  def test_csv_path
    importer = CsvImporter.new(path: 'test/fixtures/csv_data.csv')
    importer.import!
    assert_equal 'value 1', importer.result.column_1

    importer = CsvImporter.new
    importer.csv_path = 'test/fixtures/csv_data.csv'
    importer.import!
    assert_equal 'value 1', importer.result.column_1
  end

  def test_csv_file
    csv_file = File.open('test/fixtures/csv_data.csv')
    importer = CsvImporter.new(file: csv_file)
    importer.import!
    assert_equal 'value 1', importer.result.column_1

    csv_file = File.open('test/fixtures/csv_data.csv')
    importer = CsvImporter.new
    importer.csv_file = csv_file
    importer.import!
    assert_equal 'value 1', importer.result.column_1
  end

  def test_csv_string
    csv_string = <<-CSV
Column 1,Column 2
value 1,value 2
    CSV

    importer = CsvImporter.new(content: csv_string)
    importer.import!
    assert_equal 'value 1', importer.result.column_1

    importer = CsvImporter.new
    importer.csv_content = csv_string
    importer.import!
    assert_equal 'value 1', importer.result.column_1
  end

  def test_accepts_options_for_csv_object
    csv = <<-CSV
Column 1;Column 2
Value 1;Value 2
    CSV

    importer = CsvImporter.new(content: csv, col_sep: ';')
    importer.import!

    assert_equal 'Value 2', importer.result.column_2

    importer = CsvImporter.new(content: csv)
    importer.csv_options = { col_sep: ';' }
    importer.import!

    assert_equal 'Value 2', importer.result.column_2
  end

  def test_raises_error_on_unrecognized_csv_options
    assert_raises CSVParty::UnrecognizedCSVOptionsError do
      importer = CsvImporter.new
      importer.csv_options = { unrecognized_option: 42 }
    end
  end

  def test_raises_error_on_unrecognized_options
    csv = <<-CSV
Value
value
    CSV

    assert_raises CSVParty::UnrecognizedOptionsError do
      Class.new(CSVParty::Importer) do
        depends_on :dependency1, :dependency2

        column :column

        rows do
        end
      end.new(content: csv, unrecognized_option: 42)
    end
  end

  def test_raises_error_on_missing_csv
    importer = CsvImporter.new

    assert_raises CSVParty::MissingCSVError do
      importer.import!
    end
  end

  def test_raises_error_on_non_string_csv_path
    assert_raises ArgumentError do
      CsvImporter.new(path: 1)
    end

    assert_raises ArgumentError do
      importer = CsvImporter.new
      importer.csv_path = 1
    end
  end

  def test_raises_error_on_invalid_csv_path
    invalid_path = 'invalid/path/to/file'

    assert_raises CSVParty::NonexistentCSVFileError do
      CsvImporter.new(path: invalid_path)
    end

    assert_raises CSVParty::NonexistentCSVFileError do
      importer = CsvImporter.new
      importer.csv_path = invalid_path
    end
  end

  def test_raises_error_on_non_io_csv_file
    assert_raises ArgumentError do
      CsvImporter.new(file: 1)
    end

    assert_raises ArgumentError do
      importer = CsvImporter.new
      importer.csv_file = 1
    end
  end

  def test_raises_error_on_non_string_csv_content
    assert_raises ArgumentError do
      CsvImporter.new(content: 1)
    end

    assert_raises ArgumentError do
      importer = CsvImporter.new
      importer.csv_content = 1
    end
  end
end

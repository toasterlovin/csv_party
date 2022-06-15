require 'test_helper'

class CsvDataTest < Minitest::Test
  class CsvImporter
    include CSVParty

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
  end

  def test_csv_file
    csv_file = File.open('test/fixtures/csv_data.csv')
    importer = CsvImporter.new(file: csv_file)
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
  end

  def test_accepts_options_for_csv_object
    csv = <<-CSV
Column 1;Column 2
Value 1;Value 2
    CSV

    importer = CsvImporter.new(content: csv, col_sep: ';')
    importer.import!

    assert_equal 'Value 2', importer.result.column_2
  end

  def test_accepts_encoding_option
    path = 'test/fixtures/iso_8859_1.csv'

    assert_raises CSV::MalformedCSVError do
      CsvImporter.new(path: path).import!
    end

    importer = CsvImporter.new(path: path, encoding: 'ISO-8859-1:UTF-8')
    importer.import!

    assert_equal 'è', importer.result.column_2
  end

  def test_raises_error_on_unrecognized_options
    csv = <<-CSV
Value
value
    CSV

    assert_raises CSVParty::UnrecognizedOptionsError do
      Class.new do
        include CSVParty

        depends_on :dependency1, :dependency2

        column :column

        rows do
        end
      end.new(content: csv, unrecognized_option: 42)
    end
  end

  def test_raises_error_on_missing_csv
    assert_raises CSVParty::MissingCSVError do
      CsvImporter.new
    end
  end

  def test_raises_error_on_invalid_csv_path
    invalid_path = 'invalid/path/to/file'

    assert_raises CSVParty::NonexistentCSVFileError do
      CsvImporter.new(path: invalid_path)
    end
  end
end

require 'test_helper'

class ErrorHandlingTest < Minitest::Test
  def setup
    @csv = <<-CSV
Value
raise
import
    CSV
  end

  def test_raises_errors_by_default
    importer = Class.new do
      include CSVParty

      column :value

      rows do
        raise TestCaseError
      end
    end.new(content: @csv)

    assert_raises TestCaseError do
      importer.import!
    end
  end

  def test_ignoring_errors
    importer = Class.new do
      include CSVParty

      column :value

      rows do |row|
        raise TestCaseError if row.value == 'raise'
        self.result = row
      end

      errors :ignore
    end.new(content: @csv)

    importer.import!

    assert_equal 'import', importer.result.value

    assert_equal 1, importer.error_rows.count

    error = importer.error_rows.first
    assert_instance_of TestCaseError, error.error
    assert_equal 2, error.line_number
    assert_equal "raise\n", error.csv_string
  end

  def test_custom_error_handling
    importer = Class.new do
      include CSVParty

      column :value

      rows do |row|
        raise TestCaseError if row.value == 'raise'

        result[:success] = row
      end

      errors do |error, line_number, csv_string|
        result[:error] = error
        result[:line_number] = line_number
        result[:csv_string] = csv_string
      end
    end.new(content: @csv)

    importer.result = {}
    importer.import!

    assert_equal 'import', importer.result[:success].value

    assert importer.error_rows.empty?

    assert_instance_of TestCaseError, importer.result[:error]
    assert_equal 2, importer.result[:line_number]
    assert_equal "raise\n", importer.result[:csv_string]
  end

  def test_does_not_capture_malformed_csv_errors
    malformed_csv = <<-CSV
First,Second
value1,value2
"Improperly escaped \"quotes\"",3
    CSV

    importer = Class.new do
      include CSVParty

      column :first
      column :second, as: :integer

      rows do
      end

      errors :ignore
    end.new(content: malformed_csv)

    assert_raises CSV::MalformedCSVError do
      importer.import!
    end
  end
end

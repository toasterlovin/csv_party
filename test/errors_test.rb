require 'test_helper'

class ErrorsTest < Minitest::Test
  def test_raises_errors_by_default
    importer = NoErrorHandlerImporter.new('test/csv/errors.csv')

    assert_raises TestCaseError do
      importer.import!
    end
  end

  def test_ignoring_errors
    importer = IgnoreErrorsImporter.new('test/csv/errors.csv')
    importer.import!

    assert_equal 'import', importer.result.value

    assert_equal 1, importer.error_rows.count

    error = importer.error_rows.first
    assert_instance_of TestCaseError, error.error
    assert_equal 2, error.line_number
    assert_equal "raise\n", error.csv_string
  end

  def test_custom_error_handling
    importer = CustomErrorHandlerImporter.new('test/csv/errors.csv')
    importer.result = {}
    importer.import!

    assert_equal 'import', importer.result[:success].value

    assert importer.error_rows.empty?

    assert_instance_of TestCaseError, importer.result[:error]
    assert_equal 2, importer.result[:line_number]
    assert_equal "raise\n", importer.result[:csv_string]
  end

  def test_does_not_capture_malformed_csv_errors
    importer = MalformedCSVErrorImporter.new('test/csv/malformed_csv_error.csv')

    assert_raises CSV::MalformedCSVError do
      importer.import!
    end
  end
end

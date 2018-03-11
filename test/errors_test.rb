require 'test_helper'

class ErrorsTest < Minitest::Test
  def test_captures_malformed_csv_errors
    importer = MalformedCSVErrorImporter.new('test/csv/malformed_csv_error.csv')
    importer.import!

    assert importer.result.first.is_a? CSV::MalformedCSVError
    assert_equal 2, importer.result.last
  end
end

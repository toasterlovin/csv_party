require 'test_helper'

class NextRowTest < Minitest::Test
  def test_next_row_works
    importer = NextRowImporter.new('test/csv/next_row.csv')
    importer.result = []
    importer.import!

    result = importer.result.first
    assert_equal 1, importer.result.count
    assert_equal 'Import', result.action
    assert_equal 'Value2', result.value
  end
end

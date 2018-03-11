require 'test_helper'

class FileImportTest < Minitest::Test
  def test_import_block
    importer = ImportBlockImporter.new('test/csv/import_block.csv')
    importer.result = {}
    importer.result[:rows] = []
    importer.import!

    assert_equal 'Before', importer.result[:before]
    assert_equal 'After', importer.result[:after]
    assert_equal 'Value 1', importer.result[:rows].first.value
    assert_equal 'Value 2', importer.result[:rows].last.value
  end
end

require 'test_helper'

class AbortedImportTest < Minitest::Test
  def test_happy_path_returns_true
    importer = HappyPathImporter.new('test/csv/happy_path.csv')
    importer.result = []
    assert importer.import!
  end

  def test_aborted_import
    importer = AbortedImportImporter.new('test/csv/aborted_import.csv')
    importer.result = {}

    refute importer.import!
    assert importer.aborted?
    assert_equal 'Import was aborted', importer.abort_message
    assert_equal 'Before importing rows', importer.result[:before]
    assert_nil importer.result[:after]
  end
end

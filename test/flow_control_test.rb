require 'test_helper'

class FlowControlTest < Minitest::Test
  def test_skipped_rows
    importer = SkippedRowsImporter.new('test/csv/skipped_rows.csv')
    importer.import!

    assert_equal 'Imported', importer.result
    assert_equal 2, importer.imported_rows.first
    assert_equal 3, importer.skipped_rows.first
  end

  def test_aborted_rows
    importer = AbortedRowsImporter.new('test/csv/aborted_rows.csv')
    importer.result = {}
    importer.import!

    assert_equal 'Imported', importer.result[:imported]
    assert_equal 2, importer.imported_rows.first
    assert importer.result[:aborted].is_a? CSVParty::AbortedRowError
    assert_equal 'This row was aborted.', importer.result[:aborted].message
    assert_equal 3, importer.aborted_rows.first
  end

  def test_aborted_import
    importer = AbortedImportImporter.new('test/csv/aborted_import.csv')
    importer.result = {}
    importer.import!

    assert importer.aborted?
    assert_equal 'Import was aborted', importer.abort_message
    assert_equal 1, importer.imported_rows.size
    assert_equal 'Before importing rows', importer.result[:before]
    assert_nil importer.result[:after]
  end
end

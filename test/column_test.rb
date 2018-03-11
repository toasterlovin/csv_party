require 'test_helper'

class ColumnTest < Minitest::Test
  def test_header_is_not_required
    flunk
  end

  def test_column_header_is_case_insensitive_by_default
    flunk
  end

  def test_column_header_ignores_whitespace_by_default
    flunk
  end

  def test_duplicate_columns
    flunk 'should raise error at import time, not class definition time'

    assert_raises CSVParty::DuplicateColumnError do
      require 'importers/invalid/duplicate_columns_importer'
    end
  end

  def test_missing_column_in_csv
    assert_raises CSVParty::MissingColumnError do
      MissingColumnImporter.new('test/csv/missing_column.csv')
    end
  end
end

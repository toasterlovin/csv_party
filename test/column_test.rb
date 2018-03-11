require 'test_helper'

class ColumnTest < Minitest::Test
  def test_duplicate_columns
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

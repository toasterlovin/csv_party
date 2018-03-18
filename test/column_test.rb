require 'test_helper'

class ColumnTest < Minitest::Test
  def test_automatic_header_matching
    importer = ColumnTestImporter.new('test/csv/column_test.csv')
    importer.import!
    assert_equal 'exact', importer.result.exact
    assert_equal 'multi_word_exact', importer.result.multi_word_exact
    assert_equal 'whitespace', importer.result.whitespace
    assert_equal 'lower', importer.result.lower
    assert_equal 'multi word lower', importer.result.multi_word_lower
    assert_equal 'Title', importer.result.title
    assert_equal 'Multi Word Title', importer.result.multi_word_title
    assert_equal 'CAPS', importer.result.caps
    assert_equal 'MULTI WORD CAPS', importer.result.multi_word_caps
    assert_equal 'mIxEd', importer.result.mixed
    assert_equal 'MuLtI wOrD mIxEd', importer.result.multi_word_mixed
  end

  def test_specifying_column_header_with_string
    importer = ColumnTestImporter.new('test/csv/column_test.csv')
    importer.import!
    assert_equal 'String', importer.result.string_header
  end

  def test_specifying_column_header_with_regex
    importer = ColumnTestImporter.new('test/csv/column_test.csv')
    importer.import!
    assert_equal 'regex7', importer.result.regex_header
  end

  def test_duplicate_columns
    assert_raises CSVParty::DuplicateColumnError do
      require 'importers/invalid/duplicate_column_importer'
    end
  end

  def test_missing_column_in_csv
    assert_raises CSVParty::MissingColumnError do
      MissingColumnImporter.new('test/csv/missing_column.csv')
    end
  end
end

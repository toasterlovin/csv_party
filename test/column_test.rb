require 'test_helper'

class ColumnTest < Minitest::Test
  class ColumnTestImporter < CSVParty::Importer
    column :exact
    column :multi_word_exact
    column :whitespace
    column :lower
    column :multi_word_lower
    column :title
    column :multi_word_title
    column :caps
    column :multi_word_caps
    column :mixed
    column :multi_word_mixed
    column :string_header, header: 'String'
    column :regex_header, header: /regex[\d]/

    rows do |row|
      self.result = row
    end
  end

  def setup
    @csv = <<-CSV
exact,multi_word_exact, whitespace ,lower,multi word lower,Title,Multi Word Title,CAPS,MULTI WORD CAPS,mIxEd,MuLtI wOrD mIxEd,String,regex7
exact,multi_word_exact,whitespace,lower,multi word lower,Title,Multi Word Title,CAPS,MULTI WORD CAPS,mIxEd,MuLtI wOrD mIxEd,String,regex7
    CSV
  end

  def test_automatic_header_matching
    importer = ColumnTestImporter.new(@csv)
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
    importer = ColumnTestImporter.new(@csv)
    importer.import!
    assert_equal 'String', importer.result.string_header
  end

  def test_specifying_column_header_with_regex
    importer = ColumnTestImporter.new(@csv)
    importer.import!
    assert_equal 'regex7', importer.result.regex_header
  end

  def test_duplicate_columns
    assert_raises CSVParty::DuplicateColumnError do
      Class.new(CSVParty::Importer) do
        column :product
        column :product
      end
    end
  end

  def test_missing_column_in_csv
    csv = <<-CSV
Present,Other
value,value
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :present
      column :missing
      column :missing_with_header, header: 'Defined1234'

      rows do
      end
    end.new(csv)

    assert_raises CSVParty::MissingColumnError do
      importer.import!
    end

    assert_equal %w[Present Other], importer.present_columns
    assert_equal %w[missing Defined1234], importer.missing_columns
  end

  def test_reserved_column_names
    assert_raises CSVParty::ReservedColumnNameError do
      Class.new(CSVParty::Importer) do
        column :unparsed
      end
    end

    assert_raises CSVParty::ReservedColumnNameError do
      Class.new(CSVParty::Importer) do
        column :csv_string
      end
    end

    assert_raises CSVParty::ReservedColumnNameError do
      Class.new(CSVParty::Importer) do
        column :row_number
      end
    end
  end
end

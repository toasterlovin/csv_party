require 'test_helper'

class FileImportTest < Minitest::Test
  def setup
    @csv = <<-CSV
Value
Value 1
Value 2
    CSV
  end

  def test_import_block
    importer = Class.new(CSVParty::Importer) do
      column :value

      rows do |row|
        result[:rows] << row
      end

      import do
        result[:before] = 'Before'
        import_rows!
        result[:after] = 'After'
      end
    end.new(content: @csv)

    importer.result = {}
    importer.result[:rows] = []
    importer.import!

    assert_equal 'Before', importer.result[:before]
    assert_equal 'After', importer.result[:after]
    assert_equal 'Value 1', importer.result[:rows].first.value
    assert_equal 'Value 2', importer.result[:rows].last.value
  end

  def test_raises_error_when_rows_are_not_imported
    importer = Class.new(CSVParty::Importer) do
      column :value

      rows do
      end

      import do
      end
    end.new(content: @csv)

    assert_raises CSVParty::UnimportedRowsError do
      importer.import!
    end
  end
end

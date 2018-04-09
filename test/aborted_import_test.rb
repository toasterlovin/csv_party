require 'test_helper'

class AbortedImportTest < Minitest::Test
  def test_aborted_import
    csv = <<-CSV
Action,Value
Import,Value2
Abort,Value2
Import,Value2
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :action
      column :value

      rows do |row|
        abort_import! 'Import was aborted' if row.action == 'Abort'
      end

      import do
        result[:before] = 'Before importing rows'
        import_rows!
        result[:after] = 'After importing rows'
      end
    end.new(csv)

    importer.result = {}

    refute importer.import!
    assert importer.aborted?
    assert_equal 'Import was aborted', importer.abort_message
    assert_equal 'Before importing rows', importer.result[:before]
    assert_nil importer.result[:after]
  end
end

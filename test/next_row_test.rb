require 'test_helper'

class NextRowTest < Minitest::Test
  def test_next_row_works
    csv = <<-CSV
Action,Value
Next,Value1
Import,Value2
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :action
      column :value

      rows do |row|
        if row.action == 'Next'
          next_row!
        else
          result << row
        end
      end
    end.new(content: csv)

    importer.result = []
    importer.import!

    result = importer.result.first
    assert_equal 1, importer.result.count
    assert_equal 'Import', result.action
    assert_equal 'Value2', result.value
  end
end

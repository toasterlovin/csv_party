require 'test_helper'

class AbortedRowTest < Minitest::Test
  def setup
    @csv = <<-CSV
Action,Value
Imported,Value1
Aborted,Value2
Aborted,Value3
    CSV
  end

  def test_default_aborted_row_behavior
    importer = Class.new do
      include CSVParty

      column :action
      column :value

      rows do |row|
        abort_row! 'aborted row' if row.first == 'Aborted'
        self.result = row
      end
    end.new(content: @csv)

    importer.import!

    assert_equal 'Imported', importer.result.action
    assert_equal 'Value1', importer.result.value

    aborted_row = importer.aborted_rows.first
    assert_equal 2, importer.aborted_rows.count
    assert_equal 'Aborted', aborted_row.action
    assert_equal 'Value2', aborted_row.value
    assert_equal 'aborted row', aborted_row.abort_message
    assert_equal 3, aborted_row.row_number
  end

  def test_ignoring_aborted_rows
    importer = Class.new do
      include CSVParty

      column :action
      column :value

      rows do |row|
        abort_row! if row.first == 'Aborted'
        self.result = row
      end

      aborted_rows :ignore
    end.new(content: @csv)

    importer.import!

    assert_equal 'Imported', importer.result.action
    assert_equal 'Value1', importer.result.value

    assert importer.aborted_rows.empty?
  end

  def test_custom_aborted_row_handler
    importer = Class.new do
      include CSVParty

      column :action
      column :value

      rows do |row|
        abort_row! 'aborted row' if row.first == 'Aborted'
        result[:not_aborted] = row
      end

      aborted_rows do |row|
        result[:aborted] = row
      end
    end.new(content: @csv)

    importer.result = {}
    importer.import!

    assert_equal 'Imported', importer.result[:not_aborted].action
    assert_equal 'Value1', importer.result[:not_aborted].value

    assert importer.aborted_rows.empty?
    assert_equal 'Aborted', importer.result[:aborted].action
    assert_equal 'Value3', importer.result[:aborted].value
    assert_equal 'aborted row', importer.result[:aborted].abort_message
  end

  def test_abort_message_is_reserved_column
    assert_raises CSVParty::ReservedColumnNameError do
      Class.new do
        include CSVParty

        column :abort_message
      end
    end
  end
end

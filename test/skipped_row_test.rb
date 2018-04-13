require 'test_helper'

class SkippedRowTest < Minitest::Test
  def setup
    @csv = <<-CSV
Action,Value
Imported,Value1
Skipped,Value2
Skipped,Value3
    CSV
  end

  def test_default_skipped_row_behavior
    importer = Class.new(CSVParty::Importer) do
      column :action
      column :value

      rows do |row|
        skip_row! 'skipped row' if row.first == 'Skipped'
        self.result = row
      end
    end.new(content: @csv)

    importer.import!

    assert_equal 'Imported', importer.result.action
    assert_equal 'Value1', importer.result.value

    skipped_row = importer.skipped_rows.first
    assert_equal 2, importer.skipped_rows.count
    assert_equal 'Skipped', skipped_row.action
    assert_equal 'Value2', skipped_row.value
    assert_equal 'skipped row', skipped_row.skip_message
    assert_equal 3, skipped_row.row_number
  end

  def test_ignoring_skipped_rows
    importer = Class.new(CSVParty::Importer) do
      column :action
      column :value

      rows do |row|
        skip_row! if row.first == 'Skipped'
        self.result = row
      end

      skipped_rows :ignore
    end.new(content: @csv)

    importer.import!

    assert_equal 'Imported', importer.result.action
    assert_equal 'Value1', importer.result.value

    assert importer.skipped_rows.empty?
  end

  def test_custom_skipped_row_handler
    importer = Class.new(CSVParty::Importer) do
      column :action
      column :value

      rows do |row|
        skip_row! 'skipped row' if row.first == 'Skipped'
        result[:not_skipped] = row
      end

      skipped_rows do |row|
        result[:skipped] = row
      end
    end.new(content: @csv)

    importer.result = {}
    importer.import!

    assert_equal 'Imported', importer.result[:not_skipped].action
    assert_equal 'Value1', importer.result[:not_skipped].value

    assert importer.skipped_rows.empty?
    assert_equal 'Skipped', importer.result[:skipped].action
    assert_equal 'Value3', importer.result[:skipped].value
    assert_equal 'skipped row', importer.result[:skipped].skip_message
  end

  def test_skip_message_is_reserved_column
    assert_raises CSVParty::ReservedColumnNameError do
      Class.new(CSVParty::Importer) do
        column :skip_message
      end
    end
  end
end

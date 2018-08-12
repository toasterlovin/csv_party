require 'test_helper'

class RowImportTest < Minitest::Test
  def test_provides_access_to_raw_row_values_in_import_block
    csv = <<-CSV
String,Integer
 Has whitespace ,1
    CSV

    importer = Class.new do
      include CSVParty

      column :whitespace, header: 'String', as: :string

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal 'Has whitespace', importer.result.whitespace
    assert_equal ' Has whitespace ', importer.result.unparsed.whitespace
  end

  def test_provides_access_to_csv_row_as_string
    csv = <<-CSV
Column 1,Column 2
Some text,2
    CSV

    importer = Class.new do
      include CSVParty

      column :column_1, header: 'Column 1', as: :string
      column :column_2, header: 'Column 2', as: :integer

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal 'Some text', importer.result.column_1
    assert_equal csv.lines.last, importer.result.csv_string
  end

  def test_provides_access_to_csv_row_number
    csv = <<-CSV
Product
tshirt
belt
    CSV

    importer = Class.new do
      include CSVParty

      column :product

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal 3, importer.result.row_number
  end

  def test_raises_error_if_row_processor_is_undefined
    csv = <<-CSV
Product
tshirt
    CSV

    importer = Class.new do
      include CSVParty

      column :product
    end.new(content: csv)

    assert_raises CSVParty::UndefinedRowProcessorError do
      importer.import!
    end
  end

  def test_raises_error_when_accessing_undefined_column
    csv = <<-CSV
Product,Price
tshirt,10.99
    CSV

    importer = Class.new do
      include CSVParty

      column :product
      column :price, as: :decimal

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    refute importer.result.respond_to?(:undefined)
    assert_raises NoMethodError do
      importer.result.undefined
    end
  end
end

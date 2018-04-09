require 'test_helper'

class HappyPathTest < Minitest::Test
  def test_happy_path
    csv = <<-CSV
Product,Price
Widget,9.99
Gadget,12.99
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :product, as: :string
      column :price, as: :decimal

      rows do |row|
        result << row
      end
    end.new(csv)

    importer.result = []
    assert importer.import!

    row_one = importer.result[0]
    assert_equal 'Widget', row_one.product
    assert_equal 9.99,     row_one.price

    row_two = importer.result[1]
    assert_equal 'Gadget', row_two.product
    assert_equal 12.99,    row_two.price
  end
end

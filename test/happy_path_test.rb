require 'test_helper'

class HappyPathTest < Minitest::Test
  def test_happy_path
    importer = HappyPathImporter.new('test/csv/happy_path.csv')
    importer.result = []
    importer.import!

    row_one = importer.result[0]
    assert_equal 'Widget', row_one.product
    assert_equal 9.99,     row_one.price

    row_two = importer.result[1]
    assert_equal 'Gadget', row_two.product
    assert_equal 12.99,    row_two.price
  end
end

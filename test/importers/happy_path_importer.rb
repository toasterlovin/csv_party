require 'csv_party'

class HappyPathImporter < CSVParty
  column :product, header: 'Product', as: :string
  column :price, header: 'Price', as: :decimal

  import do |row|
    $result << row
  end
end

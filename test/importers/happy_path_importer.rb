require "csv_party"

class HappyPathImporter < CSVParty
  column :product, header: "Product" do |value|
    "#{value} - parsed"
  end
  column :import, header: "Import", as: :boolean
  column :price, header: "Price", as: :decimal
  column :inventory, header: "Inventory", as: :integer

  import do |row|
    $result = row
  end
end

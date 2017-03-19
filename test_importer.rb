require "./csv_party"

class TestImporter < CSVParty
  column :product, header: "Product" do |value|
    "#{value} - parsed"
  end
  column :import, header: "Import", as: :boolean
  column :price, header: "Price", as: :decimal
  column :inventory, header: "Inventory", as: :integer

  import do |row|
  end
end

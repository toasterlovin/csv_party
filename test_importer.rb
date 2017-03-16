require "./better_csv"

class TestImporter < BetterCsv
  column :product, header: "Product" do |value|
    "Did some custom logic"
  end
  column :import, header: "Import", as: :boolean
  column :price, header: "Price", as: :decimal
  column :inventory, header: "Inventory", as: :integer

  import do |row|
    puts "Importing the data"
    puts "Product: #{row.product}"
    puts "Import: #{row.import}"
    puts "Price: #{row.product}"
    puts "Inventory: #{row.inventory}"
  end
end

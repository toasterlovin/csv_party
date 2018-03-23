require 'csv_party'

class UndefinedColumnImporter < CSVParty::Importer
  column :product
  column :price, as: :decimal

  rows do |row|
    row.undefined
  end
end

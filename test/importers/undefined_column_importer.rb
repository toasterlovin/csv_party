require 'csv_party'

class UndefinedColumnImporter < CSVParty::Importer
  column :product
  column :price, as: :decimal

  rows do |row|
    row.undefined
  end

  errors do |error|
    raise error
  end
end

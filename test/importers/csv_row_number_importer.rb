require 'csv_party'

class CsvRowNumberImporter < CSVParty::Importer
  column :product

  rows do |row|
    self.result = row
  end
end

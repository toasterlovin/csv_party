require 'csv_party'

class CsvImporter < CSVParty::Importer
  column :value

  rows do |row|
    self.result = row
  end
end

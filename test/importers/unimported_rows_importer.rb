require 'csv_party'

class UnimportedRowsImporter < CSVParty::Importer
  column :product

  rows do |row|
    self.result = row
  end

  import do
  end
end

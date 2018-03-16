require 'csv_party'

class RawParserImporter < CSVParty::Importer
  column :raw, as: :raw
  column :second_column, as: :raw

  rows do |row|
    self.result = row
  end
end

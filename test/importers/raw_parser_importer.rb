require 'csv_party'

class RawParserImporter < CSVParty
  column :raw, header: 'Raw', as: :raw
  column :second_column, header: 'Second Column', as: :raw

  rows do |row|
    self.result = row
  end
end

require 'csv_party'

class StringParserImporter < CSVParty::Importer
  column :string, as: :string
  column :second_column, as: :string

  rows do |row|
    self.result = row
  end
end

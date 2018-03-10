require 'csv_party'

class StringParserImporter < CSVParty::Importer
  column :string, header: 'String', as: :string
  column :second_column, header: 'Second Column', as: :string

  rows do |row|
    self.result = row
  end
end

require 'csv_party'

class StringParserImporter < CSVParty
  column :string, header: 'String', as: :string
  column :second_column, header: 'Second Column', as: :string

  import do |row|
    self.result = row
  end
end

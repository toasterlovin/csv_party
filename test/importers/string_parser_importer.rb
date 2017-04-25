require 'csv_party'

class StringParserImporter < CSVParty
  column :string, header: 'String', as: :string
  column :second_column, header: 'Second Column', as: :string

  import do |row|
    $result = row
  end
end

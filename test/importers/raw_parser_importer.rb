require 'csv_party'

class RawParserImporter < CSVParty
  column :raw, header: 'Raw', as: :raw
  column :second_column, header: 'Second Column', as: :raw

  import do |row|
    $result = row
  end
end

require 'csv_party'

class ParsesAsStringByDefaultImporter < CSVParty
  column :whitespace, header: 'Whitespace'

  import do |row|
    self.result = row
  end
end

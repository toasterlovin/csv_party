require 'csv_party'

class ParsesAsStringByDefaultImporter < CSVParty::Importer
  column :whitespace, header: 'Whitespace'

  rows do |row|
    self.result = row
  end
end

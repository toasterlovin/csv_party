require 'csv_party'

class CustomParserImporter < CSVParty::Importer
  column :custom, header: 'Custom' do |value|
    "#{value} plus added text"
  end

  rows do |row|
    self.result = row
  end
end

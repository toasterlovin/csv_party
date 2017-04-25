require 'csv_party'

class CustomParserImporter < CSVParty
  column :custom, header: 'Custom' do |value|
    "#{value} plus added text"
  end

  import do |row|
    self.result = row
  end
end

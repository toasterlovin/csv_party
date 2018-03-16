require 'csv_party'

class DecimalParserImporter < CSVParty::Importer
  column :decimal, as: :decimal
  column :whitespace, as: :decimal
  column :dollars, as: :decimal

  rows do |row|
    self.result = row
  end
end

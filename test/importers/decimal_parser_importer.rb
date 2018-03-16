require 'csv_party'

class DecimalParserImporter < CSVParty::Importer
  column :decimal, as: :decimal
  column :negative_decimal, as: :decimal
  column :whitespace, as: :decimal
  column :dollars, as: :decimal
  column :negative_dollars, as: :decimal

  rows do |row|
    self.result = row
  end
end

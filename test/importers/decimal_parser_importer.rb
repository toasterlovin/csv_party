require 'csv_party'

class DecimalParserImporter < CSVParty
  column :decimal, header: 'Decimal', as: :decimal
  column :whitespace, header: 'Whitespace', as: :decimal
  column :dollars, header: 'Dollars', as: :decimal

  import do |row|
    self.result = row
  end
end
